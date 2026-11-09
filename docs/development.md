# Development

## Setup

- [rustup](https://rustup.rs/). The pinned toolchain and its rustfmt and Clippy
  components are installed on first use. A `RUSTUP_TOOLCHAIN` environment
  variable overrides `rust-toolchain.toml`.
- GNU Make for the task shortcuts. Every target runs plain `cargo` commands
  that also work on Windows.
- Cargo-based tools in pinned versions: `make install-tools` (cargo-deny,
  cargo-llvm-cov, cargo-machete, cargo-nextest, typos, zizmor).
- Optional: [actionlint](https://github.com/rhysd/actionlint#installation),
  [Trivy](https://trivy.dev/latest/getting-started/installation/), and
  [Docker](https://docs.docker.com/get-docker/) for workflow and container
  checks.

The [Dev Container](../.devcontainer/devcontainer.json) installs the toolchain
and the Cargo-based tools, and it gives access to the host's Docker.

## Make targets

Run `make help` to list all targets.

| Command | What it does |
| --- | --- |
| `make run ARGS="greet -n Rust"` | run the CLI |
| `make format` / `make fix` | format code and apply Clippy suggestions |
| `make check` | `format-check`, `lint`, `doc-check`, `spell`, `machete`, `deny` |
| `make test` | nextest (unit and CLI tests) and doctests |
| `make install-msrv && make test-msrv` | tests with the MSRV read from `Cargo.toml` |
| `make coverage` / `make coverage-html` | line coverage (`lcov.info`, fails below `COVERAGE_MIN_LINES=80`) |
| `make ci-test` | `check`, `test`, and a locked release build |
| `make lint-workflows` | actionlint and zizmor on `.github/` |
| `make scan-fs` | Trivy scan of the repository (vulnerabilities, secrets, misconfigurations) |
| `make ci-test-docker` | hadolint, image build, Trivy image scan, restricted runtime test |
| `make release-tag VERSION=X.Y.Z` | push tag `vX.Y.Z` from an up-to-date `main` to start a release (see [Releasing](release.md)) |

All builds use `--locked`, and `Cargo.lock` is committed because this is an
application.

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the checks to run before opening
a pull request.
