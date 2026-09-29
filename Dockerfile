FROM rust:1.98.1-trixie AS build

WORKDIR /usr/src/app

COPY . .

RUN cargo build --release --locked

FROM debian:trixie-slim AS deployment
WORKDIR /app

COPY --from=build /usr/src/app/target/release/hello ./app

USER 65534:65534

CMD ["./app"]
