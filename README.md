[![test](https://github.com/ks6088ts/template-rust/actions/workflows/test.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/test.yaml?query=branch%3Amain)
[![docker](https://github.com/ks6088ts/template-rust/actions/workflows/docker.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/docker.yaml?query=branch%3Amain)
[![docker-release](https://github.com/ks6088ts/template-rust/actions/workflows/docker-release.yaml/badge.svg)](https://github.com/ks6088ts/template-rust/actions/workflows/docker-release.yaml)
[![ghcr-release](https://github.com/ks6088ts/template-rust/actions/workflows/ghcr-release.yaml/badge.svg)](https://github.com/ks6088ts/template-rust/actions/workflows/ghcr-release.yaml)

# template-rust

A dependency-free Rust template with a library, a small executable, and checks
for Rust, GitHub Actions, and Docker.

## Prerequisites

- [rustup](https://rustup.rs/) (installs the Rust 1.98.1 toolchain and its
  rustfmt/Clippy components from `rust-toolchain.toml`)
- [GNU Make](https://www.gnu.org/software/make/)

The crate uses Rust edition 2024 and supports Rust 1.85.0 or newer (MSRV).
Normal development and CI use the pinned 1.98.1 toolchain; `make test-msrv`
checks the minimum version separately. A global `RUSTUP_TOOLCHAIN` override
takes precedence over the repository's toolchain file.

## Local development

Use the Makefile targets from the repository root:

```shell
make format-check
make lint
make test
make test-release
rustup toolchain install 1.85.0 --profile minimal
make test-msrv
make build
make run
make ci-test
```

`make ci-test` runs formatting, warning-free Clippy on all Rust targets and
features, debug and release tests (including CLI integration tests and
doctests), and a locked release build. `make format` formats Rust files.
`make lint-workflows` additionally checks GitHub Actions files when
[actionlint](https://github.com/rhysd/actionlint#installation) is installed;
CI installs a pinned, checksum-verified actionlint release. No extra Cargo
dependencies or test runner are needed for this small example.

The example API remains `add(u64, u64) -> u64`, and `hello` prints
`2 + 2 = 4`. Overflow now panics in both debug and release builds.
`Cargo.lock` is committed because this template includes an executable;
builds and tests use `--locked`.

## Docker development

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

The default local image name is the lowercase checkout directory name, tagged
with the latest Git tag (without a leading `v`) or the commit ID. Override it
if needed, for example:
`make docker-build DOCKER_IMAGE_NAME=my-service GIT_TAG=1.2.3`.
`DOCKER_REPO_NAME=my-user` adds an optional Docker Hub namespace. If you rename
the `hello` binary, also update the executable path in `Dockerfile` and the
CLI integration test.

## Publishing images

A pushed `v1.2.3` tag publishes `<docker-user>/<repository>:1.2.3` to Docker
Hub and `ghcr.io/<owner>/<repository>:1.2.3` to GHCR. Stable releases also
publish `latest`; prereleases such as `v1.2.3-rc.1` retain their suffix and do
not overwrite `latest`. Both workflows build `linux/amd64` and `linux/arm64`
images. Adapt or remove these workflows in repositories that do not publish
containers.

For Docker Hub, create a repository with the same name as your GitHub repository
and [an access token](https://app.docker.com/settings/personal-access-tokens/create),
then set these repository secrets:

```shell
gh secret set DOCKERHUB_USERNAME --body "$DOCKERHUB_USERNAME"
gh secret set DOCKERHUB_TOKEN --body "$DOCKERHUB_TOKEN"
```

GHCR uses the workflow's `GITHUB_TOKEN`; no extra repository secret is needed.
Dependabot proposes updates to GitHub Actions, Cargo dependencies, and Docker
base images. Workflow actions use full commit SHAs with release version comments
to satisfy the repository's Actions policy; keep both aligned when updating
them. When updating Rust, keep `rust-toolchain.toml` and the Rust builder image
version in `Dockerfile` aligned. Built-in `cargo test`, rustfmt, and Clippy
provide the default Rust guardrails; tools such as cargo-nextest and cargo-deny
can be added when a derived project has enough tests or dependencies to justify
them.
