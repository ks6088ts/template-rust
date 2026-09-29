# Template notes

The toolchain is pinned in [`rust-toolchain.toml`](../rust-toolchain.toml);
[`Cargo.toml`](../Cargo.toml) declares the Rust 2024 edition and MSRV. The
[README](../README.md) explains the development commands, CI checks, optional
Docker tooling, and registry credentials. When adapting this template, replace
the example binary and update the corresponding path in
[`Dockerfile`](../Dockerfile).

## References

- [The Cargo Book > Package Layout](https://doc.rust-lang.org/cargo/guide/project-layout.html)
- [Rust Edition Guide > Rust 2024](https://doc.rust-lang.org/edition-guide/rust-2024/index.html)
- [The rustup book > Overrides](https://rust-lang.github.io/rustup/overrides.html)
- [Docker > Multi-platform image with GitHub Actions](https://docs.docker.com/build/ci/github-actions/multi-platform/)
