# Contributing

## Setup

1. Install [rustup](https://rustup.rs/). The pinned toolchain in
   `rust-toolchain.toml` is installed automatically on first use.
2. Install the development tools: `make install-tools`. Also install
   [actionlint](https://github.com/rhysd/actionlint#installation),
   [Trivy](https://trivy.dev/latest/getting-started/installation/), and
   Docker (or [hadolint](https://github.com/hadolint/hadolint)) for the
   workflow and container checks.

## Before opening a pull request

```shell
make format        # format code
make ci-test       # static checks, tests, and release build
make test-msrv     # after `make install-msrv`
make lint-workflows  # when changing .github/
make ci-test-docker  # when changing Dockerfile or runtime behavior
```

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/). Pull requests
are squash-merged, so the pull request title must follow the same format.
Release notes are generated from pull request titles and grouped by label (see
`.github/release.yml`), so label each pull request (`enhancement`, `bug`,
`documentation`, `breaking-change`, ...).

## Releasing

Maintainers choose the next version with [Semantic Versioning](https://semver.org/):

| Changes since the last release | Version bump |
| --- | --- |
| `feat!:` or `BREAKING CHANGE:` footer | major (minor while `0.x`) |
| `feat:` | minor (patch while `0.x`) |
| only `fix:` and other changes | patch |

1. Bump `version` in `Cargo.toml`, run `cargo check` to update `Cargo.lock`,
   and merge the change through a pull request (e.g. `chore: release v1.2.3`).
2. On the updated `main`, run `make release-tag`. The pushed tag starts the
   release workflow, which publishes binaries, images, and the GitHub release.
