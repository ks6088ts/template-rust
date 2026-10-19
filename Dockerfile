FROM rust:1.99.1-trixie@sha256:e259494b14672950a909b4c54527e19d29cae6ebf980672114c8bb85e5594e4a AS build

WORKDIR /usr/src/app

COPY Cargo.toml Cargo.lock rust-toolchain.toml ./
COPY src ./src

RUN cargo build --release --locked --bin hello

FROM debian:trixie-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f AS deployment
WORKDIR /app

COPY --from=build /usr/src/app/target/release/hello ./app

USER 65534:65534

CMD ["./app"]
