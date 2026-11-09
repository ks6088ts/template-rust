# Documentation

| Page | Contents |
| --- | --- |
| [CLI](cli.md) | commands, options, exit codes, code layout, adding a subcommand |
| [Development](development.md) | setup, Dev Container, `make` targets |
| [Container image](container.md) | building, running, and testing the Docker image |
| [CI/CD](ci-cd.md) | GitHub Actions workflows and recommended repository settings |
| [Releasing](release.md) | release flow, recovering from failures, verifying downloads |
| [Using this template](using-this-template.md) | renaming the project and ongoing maintenance |
| [Design notes](design.md) | why the template is built the way it is |

## What's included

| Area | Tooling |
| --- | --- |
| Toolchain | Rust 1.99.1 pinned in `rust-toolchain.toml`, edition 2024, MSRV 1.85 |
| CLI | [clap](https://docs.rs/clap) (derive, env), [clap_complete](https://docs.rs/clap_complete), [anyhow](https://docs.rs/anyhow) / [thiserror](https://docs.rs/thiserror), [tracing](https://docs.rs/tracing) |
| Static analysis | rustfmt, Clippy (`pedantic`, `-D warnings`), `[lints]` with `unsafe_code = "forbid"`, rustdoc, [typos](https://github.com/crate-ci/typos), [cargo-machete](https://github.com/bnjbvr/cargo-machete), [actionlint](https://github.com/rhysd/actionlint), [zizmor](https://docs.zizmor.sh/), [hadolint](https://github.com/hadolint/hadolint), CodeQL (Rust and Actions) |
| Vulnerability and license scanning | [cargo-deny](https://github.com/EmbarkStudios/cargo-deny) (RustSec, licenses, sources), [Trivy](https://trivy.dev/) (repository and image), dependency review, Dependabot, [OpenSSF Scorecard](https://scorecard.dev/) |
| Tests | unit, doc, and CLI tests ([assert_cmd](https://docs.rs/assert_cmd)) run by [cargo-nextest](https://nexte.st/) on Linux, macOS, and Windows, MSRV tests, coverage with [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov) |
| Container | multi-stage build, distroless `cc-debian13:nonroot` runtime, digest-pinned bases, multi-arch, SBOM and provenance |
| Release | tag-triggered releases with generated notes, binaries for 5 targets with SHA-256 checksums and build provenance attestations, images on GHCR (and optionally Docker Hub) |
