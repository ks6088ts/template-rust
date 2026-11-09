# template-rust

[![ci](https://github.com/ks6088ts/template-rust/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/ci.yaml?query=branch%3Amain)
[![security](https://github.com/ks6088ts/template-rust/actions/workflows/security.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/security.yaml?query=branch%3Amain)
[![docker](https://github.com/ks6088ts/template-rust/actions/workflows/docker.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/docker.yaml?query=branch%3Amain)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/ks6088ts/template-rust/badge)](https://scorecard.dev/viewer/?uri=github.com/ks6088ts/template-rust)

A production-ready template for Rust command-line applications. It ships a
small but realistic CLI skeleton together with the static analysis,
vulnerability scanning, container, and CI/CD setup that a project needs from
day one.

## Prerequisites

- [rustup](https://rustup.rs/) (the toolchain pinned in `rust-toolchain.toml`
  is installed on first use)
- GNU Make
- Development tools installed with `make install-tools`
- Optional: [actionlint](https://github.com/rhysd/actionlint#installation),
  [Trivy](https://trivy.dev/latest/getting-started/installation/), and
  [Docker](https://docs.docker.com/get-docker/)

The [Dev Container](.devcontainer/devcontainer.json) installs the toolchain and
the development tools, and it gives access to the host's Docker. See
[Development](docs/development.md#setup) for details.

## Documentation

- [Overview and included tooling](docs/index.md)
- [CLI](docs/cli.md): commands, exit codes, and code layout
- [Development](docs/development.md): setup and `make` targets
- [Container image](docs/container.md)
- [CI/CD](docs/ci-cd.md): workflows and repository settings
- [Releasing](docs/release.md)
- [Using this template](docs/using-this-template.md): renaming and maintenance
- [Design notes](docs/design.md)
- [Contributing](CONTRIBUTING.md) and [security policy](SECURITY.md)

## License

[MIT](LICENSE)
