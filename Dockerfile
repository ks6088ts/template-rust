FROM rust:1.99.0-trixie@sha256:81015672d6939b0265f09adf96d5de125482bb1330106076956b0518e74edc90 AS build

WORKDIR /usr/src/app

COPY . .

RUN cargo build --release --locked

FROM debian:trixie-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f AS deployment
WORKDIR /app

COPY --from=build /usr/src/app/target/release/hello ./app

USER 65534:65534

CMD ["./app"]
