FROM rust:1.99.1-trixie@sha256:8a4e90c7946b74626488b1446f712c0fe0ed1a596cbd3d871684bc9c5433ae07 AS build

WORKDIR /usr/src/app

COPY Cargo.toml Cargo.lock rust-toolchain.toml ./
COPY src ./src

RUN --mount=type=cache,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,target=/usr/src/app/target,sharing=locked \
    cargo build --release --locked --bin template-rust \
    && install -D -m 0755 target/release/template-rust /out/template-rust

# Distroless: glibc and CA certificates only; no shell or package manager.
FROM gcr.io/distroless/cc-debian13:nonroot@sha256:cb87acc574abe719b6e5c547384defa2f7b1f24af9605d3f618cf852495d8be2 AS runtime

COPY --from=build /out/template-rust /usr/local/bin/template-rust

# Numeric IDs of distroless `nonroot`, so runtimes can verify a non-root user.
USER 65532:65532

ENTRYPOINT ["/usr/local/bin/template-rust"]
CMD ["--help"]
