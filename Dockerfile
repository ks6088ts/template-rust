FROM rust:1.83.0-bullseye

WORKDIR /rust/src/app

COPY . .

RUN make build

CMD ["make", "run"]
