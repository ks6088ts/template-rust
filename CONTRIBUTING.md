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

Use [Conventional Commits](https://www.conventionalcommits.org/). release-plz
derives the next version and the changelog from them:

| Prefix | Effect |
| --- | --- |
| `feat:` | minor version bump (patch while `0.x`), listed under Added |
| `fix:` | patch version bump, listed under Fixed |
| `feat!:` or `BREAKING CHANGE:` footer | major version bump (minor while `0.x`) |
| `docs:`, `refactor:`, `test:`, `ci:`, `chore:` | can trigger a patch-release PR when packaged files change |

Pull requests are squash-merged, so the pull request title must follow the
same format.
