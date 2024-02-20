use axum::{Json, Router, routing::get};
use axum::extract::Query;
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Deserialize;
use serde_json::{json};
use tokio::signal;
use tower_http::trace::{self, TraceLayer};
use tracing::Level;
use crate::map::Coordinates;

mod map;
mod health;

#[derive(Deserialize)]
struct Request {
    x: f64,
    y: f64,
    size: u8,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_max_level(Level::DEBUG)
        .init();

    let app = Router::new()
        .route("/", get(get_map))
        .route("/healthz", get(health::get_health_status))
        .layer(
            TraceLayer::new_for_http()
                .make_span_with(trace::DefaultMakeSpan::new()
                    .level(Level::INFO))
                .on_response(trace::DefaultOnResponse::new()
                    .level(Level::INFO)),
        );

    let listener = tokio::net::TcpListener::bind("0.0.0.0:7000").await.unwrap();
    tracing::debug!("listening on {}", listener.local_addr().unwrap());

    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await.unwrap();
}

async fn get_map(query: Option<Query<Request>>) -> (StatusCode, Response) {
    let result = query
        .ok_or(String::from("No coordinates or size supplied"))
        .and_then(|request| map::get_map(&Coordinates{x: request.x, y: request.y}, request.size.into()));

    match result {
        Ok(map) => {(StatusCode::OK, Json(json!({ "map": map })).into_response())}
        Err(err) => {(StatusCode::BAD_REQUEST, err.into_response())}
    }
}

async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
        let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
        let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }
}
