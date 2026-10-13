# Template notes

The toolchain is pinned in [`rust-toolchain.toml`](../rust-toolchain.toml);
[`Cargo.toml`](../Cargo.toml) declares the Rust 2024 edition and MSRV. The
[README](../README.md) explains the development commands, OS support, error
contracts, optional Docker tooling, and registry credentials.
Its [reuse checklist](../README.md#reusing-and-maintaining-the-template) covers
renaming the example and maintaining toolchain versions and image digests.

The library stays independent of I/O. The executable uses standard-library
writers and propagates output errors without an additional error-handling crate.
`make ci-test` includes documentation checks; image publishing requires the
Rust and Docker checks to pass for the tagged commit.

## References

- [The Cargo Book > Package Layout](https://doc.rust-lang.org/cargo/guide/project-layout.html)
- [Rust Edition Guide > Rust 2024](https://doc.rust-lang.org/edition-guide/rust-2024/index.html)
- [The rustup book > Overrides](https://rust-lang.github.io/rustup/overrides.html)
- [The Rust standard library > Write](https://doc.rust-lang.org/std/io/trait.Write.html)
- [Docker > Multi-platform image with GitHub Actions](https://docs.docker.com/build/ci/github-actions/multi-platform/)
