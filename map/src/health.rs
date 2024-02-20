use axum::http::StatusCode;
use axum::Json;
use serde_json::{json, Value};

pub async fn get_health_status() -> (StatusCode, Json<Value>) {
    (StatusCode::OK, Json(json!({ "response": "ok" })))
}
