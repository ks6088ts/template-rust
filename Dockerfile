FROM rust:1.83.0-bullseye AS build

WORKDIR /usr/src/app

COPY . .

RUN make build

FROM debian:bullseye-slim AS deployment
WORKDIR /usr/local/bin

COPY --from=build /usr/src/app/target/release/hello ./app

CMD ["./app"]
