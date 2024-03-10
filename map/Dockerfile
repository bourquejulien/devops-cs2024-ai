ARG NAME=map

FROM rust:1.75-alpine3.19 as build
ARG NAME

RUN apk add --no-cache musl-dev

RUN USER=root cargo new --bin $NAME
WORKDIR /$NAME

COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

RUN cargo build --release
RUN rm src/*.rs

COPY ./src ./src

RUN rm ./target/release/deps/$NAME*
RUN cargo build --release

FROM alpine:3.19.1 as final
ARG NAME
EXPOSE 80

WORKDIR /app
COPY --from=build /$NAME/target/release/$NAME app

ENTRYPOINT ["/app/app"]
