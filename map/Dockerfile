ARG NAME=map

FROM rust:1.75 as build
ARG NAME
RUN USER=root cargo new --bin $NAME
WORKDIR /$NAME

COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

RUN cargo build --release
RUN rm src/*.rs

COPY ./src ./src

RUN rm ./target/release/deps/$NAME*
RUN cargo build --release

FROM rust:1.75-slim-bookworm as final
ARG NAME
EXPOSE 80

WORKDIR /app
COPY --from=build /$NAME/target/release/$NAME app

ENTRYPOINT ["/app/app"]
