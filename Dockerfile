FROM rust:1.99.0-trixie@sha256:81015672d6939b0265f09adf96d5de125482bb1330106076956b0518e74edc90 AS build

WORKDIR /usr/src/app

COPY Cargo.toml Cargo.lock rust-toolchain.toml ./
COPY src ./src

RUN cargo build --release --locked --bin hello

FROM debian:trixie-slim@sha256:62bd423aeee912639ca8ee681c2b762cb3e25137e0a92b20be455898a9f034ad AS deployment
WORKDIR /app

COPY --from=build /usr/src/app/target/release/hello ./app

USER 65534:65534

CMD ["./app"]
