[![test](https://github.com/ks6088ts/template-rust/actions/workflows/test.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/test.yaml?query=branch%3Amain)
[![docker](https://github.com/ks6088ts/template-rust/actions/workflows/docker.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/docker.yaml?query=branch%3Amain)
[![docker-release](https://github.com/ks6088ts/template-rust/actions/workflows/docker-release.yaml/badge.svg)](https://github.com/ks6088ts/template-rust/actions/workflows/docker-release.yaml)
[![ghcr-release](https://github.com/ks6088ts/template-rust/actions/workflows/ghcr-release.yaml/badge.svg)](https://github.com/ks6088ts/template-rust/actions/workflows/ghcr-release.yaml)

# template-rust

A dependency-free Rust template with a library, a small executable, and built-in
tests. Docker development and image publishing are optional.

## Prerequisites

- [rustup](https://rustup.rs/) (installs the Rust 1.99.0 toolchain and its
  rustfmt/Clippy components from `rust-toolchain.toml`)
- [GNU Make](https://www.gnu.org/software/make/) for the convenience targets;
  Cargo commands can also be run directly, including on Windows

The crate uses Rust edition 2024 and supports Rust 1.85.0 or newer (MSRV).
Normal development and CI use the pinned 1.99.0 toolchain; `make test-msrv`
checks the minimum version separately. A global `RUSTUP_TOOLCHAIN` override
takes precedence over the repository's toolchain file.

## Local development

Start from the repository root:

```shell
cargo run --locked --bin hello
cargo test --workspace --all-features --locked
```

The executable prints `2 + 2 = 4`. Output errors are returned as
`std::io::Result`, reported on stderr, and cause a nonzero exit instead of a panic.
The library API is `add(u64, u64) -> u64`; it deliberately panics on overflow in
both debug and release builds.

Use the Makefile targets for the complete checks:

```shell
make format-check
make lint
make test
make test-release
make doc-check
rustup toolchain install 1.85.0 --profile minimal
make test-msrv
make build
make run
make ci-test
```

`make ci-test` runs formatting, warning-free Clippy on all Rust targets and
features, debug and release tests (including CLI integration tests and
doctests), warning-free documentation builds, and a locked release build.
CI runs these checks on Linux, adds Cargo tests on macOS and Windows, and tests
the MSRV separately. `make format` formats Rust files.
`make lint-workflows` additionally checks GitHub Actions files when
[actionlint](https://github.com/rhysd/actionlint#installation) is installed;
CI installs a pinned, checksum-verified actionlint release. No extra Cargo
dependencies or test runner are needed.

`Cargo.lock` is committed because this template includes an executable;
builds and tests use `--locked`.

## Optional Docker development

[Docker](https://docs.docker.com/get-docker/) is needed for image builds and
execution. `make docker-lint` uses the pinned
`hadolint/hadolint:v2.15.1-alpine` image when Docker is available, or an
installed local `hadolint` when it is not.
`make docker-scan` requires [Trivy](https://trivy.dev/latest/getting-started/installation/)
and fails if it finds fixable HIGH or CRITICAL vulnerabilities. Docker CI
installs a pinned, checksum-verified Trivy release.

```shell
make docker-lint
make docker-build
make docker-run
make docker-scan
make ci-test-docker
```

`make ci-test-docker` runs lint, build, scan, and execution in that order, stops
on failure, and preserves the order even with `make -j`.
The multi-stage image runs as a non-root user. Builder and runtime images are
pinned by version tag and multi-platform digest.

The default local image name is the lowercase checkout directory name, tagged
with the latest Git tag (without a leading `v`) or the commit ID. Override it
if needed, for example:
`make docker-build DOCKER_IMAGE_NAME=my-service GIT_TAG=1.2.3`.
`DOCKER_REPO_NAME=my-user` adds an optional Docker Hub namespace. If you rename
the `hello` binary, also update the executable path in `Dockerfile` and the
CLI integration test.

## Optional image publishing

A pushed `v1.2.3` tag publishes `<docker-user>/<repository>:1.2.3` to Docker
Hub and `ghcr.io/<owner>/<repository>:1.2.3` to GHCR. Stable releases also
publish `latest`; prereleases such as `v1.2.3-rc.1` retain their suffix and do
not overwrite `latest`. Both workflows build `linux/amd64` and `linux/arm64`
images. Both publishing workflows require the Rust and Docker checks to pass
for the tagged commit before logging in to a registry or publishing.
Adapt or remove these workflows in repositories that do not publish containers.

For Docker Hub, create a repository with the same name as your GitHub repository
and [an access token](https://app.docker.com/settings/personal-access-tokens/create),
then set these repository secrets:

```shell
gh secret set DOCKERHUB_USERNAME --body "$DOCKERHUB_USERNAME"
gh secret set DOCKERHUB_TOKEN --body "$DOCKERHUB_TOKEN"
```

GHCR uses the workflow's `GITHUB_TOKEN`; no extra repository secret is needed.
The two registries remain independent; GHCR does not need Docker Hub credentials.

## Reusing and maintaining the template

- Update the package name, version, description, license, README links, and
  registry configuration for your project.
- Replace the example API and executable together with their tests. If you
  rename `hello`, update `Dockerfile` and `CARGO_BIN_EXE_hello` in the integration
  test.
- Keep `Cargo.lock` tracked. Build and test commands use `--locked`.
- Dependabot proposes GitHub Actions, Cargo, and Docker version/digest updates.
  When updating Rust, keep `rust-toolchain.toml`, the Rust builder version and
  digest in `Dockerfile`, and this README aligned. Dependabot's Docker updates
  do not update the toolchain file automatically.
- Keep Actions commit SHAs and their version comments aligned, and verify
  download checksums when updating actionlint or Trivy.
- Add dependencies and tooling only when the derived project needs them;
  standard Cargo tests, rustfmt, and Clippy are the default guardrails.
