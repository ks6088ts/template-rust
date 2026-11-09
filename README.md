# template-rust

[![ci](https://github.com/ks6088ts/template-rust/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/ci.yaml?query=branch%3Amain)
[![security](https://github.com/ks6088ts/template-rust/actions/workflows/security.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/security.yaml?query=branch%3Amain)
[![docker](https://github.com/ks6088ts/template-rust/actions/workflows/docker.yaml/badge.svg?branch=main)](https://github.com/ks6088ts/template-rust/actions/workflows/docker.yaml?query=branch%3Amain)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/ks6088ts/template-rust/badge)](https://scorecard.dev/viewer/?uri=github.com/ks6088ts/template-rust)

A production-ready template for Rust command-line applications. It ships a
small but realistic CLI skeleton together with the static analysis,
vulnerability scanning, container, and CI/CD setup that a project needs from
day one.

## What's included

| Area | Tooling |
| --- | --- |
| Toolchain | Rust 1.99.1 pinned in `rust-toolchain.toml`, edition 2024, MSRV 1.85 |
| CLI | [clap](https://docs.rs/clap) (derive, env), [clap_complete](https://docs.rs/clap_complete), [anyhow](https://docs.rs/anyhow) / [thiserror](https://docs.rs/thiserror), [tracing](https://docs.rs/tracing) |
| Static analysis | rustfmt, Clippy (`pedantic`, `-D warnings`), `[lints]` with `unsafe_code = "forbid"`, rustdoc, [typos](https://github.com/crate-ci/typos), [cargo-machete](https://github.com/bnjbvr/cargo-machete), [actionlint](https://github.com/rhysd/actionlint), [zizmor](https://docs.zizmor.sh/), [hadolint](https://github.com/hadolint/hadolint), CodeQL (Rust and Actions) |
| Vulnerability and license scanning | [cargo-deny](https://github.com/EmbarkStudios/cargo-deny) (RustSec, licenses, sources), [Trivy](https://trivy.dev/) (repository and image), dependency review, Dependabot, [OpenSSF Scorecard](https://scorecard.dev/) |
| Tests | unit, doc, and CLI tests ([assert_cmd](https://docs.rs/assert_cmd)) run by [cargo-nextest](https://nexte.st/) on Linux, macOS, and Windows, MSRV tests, coverage with [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov) |
| Container | multi-stage build, distroless `cc-debian13:nonroot` runtime, digest-pinned bases, multi-arch, SBOM and provenance |
| Release | [release-plz](https://release-plz.dev/) release PRs and changelog, binaries for 5 targets with SHA-256 checksums and build provenance attestations, images on GHCR (and optionally Docker Hub) |

## Quick start

```shell
cargo run -- greet --name Rust        # Hello, Rust!
cargo run -- --help
make help                              # list all development tasks
```

## The CLI

```text
Usage: template-rust [OPTIONS] <COMMAND>

Commands:
  greet        Print a greeting
  completions  Generate a shell completion script

Options:
  -v, --verbose...  Increase log verbosity (-v: info, -vv: debug, -vvv: trace)
  -q, --quiet       Disable log output
```

- `greet [--name <NAME>]` prints `Hello, <NAME>!`. The name can also come from
  `TEMPLATE_RUST_NAME` and defaults to `World`. Command-line values take
  precedence over environment variables.
- `completions <bash|elvish|fish|powershell|zsh>` writes a completion script,
  for example `template-rust completions zsh > ~/.zfunc/_template-rust`.
- Command output goes to stdout. Logs and errors go to stderr. `RUST_LOG`
  (for example `RUST_LOG=debug`) overrides `-v`/`-q`.

Exit codes:

| Code | Meaning |
| --- | --- |
| 0 | success, `--help`, `--version`, or the reader closed the pipe (e.g. `\| head`) |
| 1 | runtime error, reported as `error: <cause chain>` |
| 2 | invalid command-line usage |

### Code layout

```text
src/
├── main.rs            # entry point: parse args, init logging, map errors to exit codes
├── lib.rs             # `run()` dispatches subcommands; the library is fully testable
├── cli.rs             # clap definitions (global flags, subcommands, arguments)
├── logging.rs         # tracing subscriber writing to stderr
├── error.rs           # typed library errors (thiserror)
└── commands/          # one module per subcommand
    ├── greet.rs
    └── completions.rs
tests/cli.rs           # end-to-end tests against the compiled binary
```

The library returns typed errors (`template_rust::Error`). Only the binary uses
`anyhow` to add context and print the cause chain. Commands write to a
generic `impl Write`, so unit tests check output in memory.

To add a subcommand, add a variant to `cli::Command` with an `Args` struct,
create `src/commands/<name>.rs` with `pub fn run(args, out) -> Result<()>`,
dispatch it in `lib.rs::run`, and add unit and CLI tests.

## Development

Prerequisites:

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

The [Dev Container](.devcontainer/devcontainer.json) installs the toolchain and
the Cargo-based tools, and it gives access to the host's Docker.

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

All builds use `--locked`, and `Cargo.lock` is committed because this is an
application.

## Container image

```shell
make docker-build
make docker-run DOCKER_COMMAND="greet --name Docker"
docker run --rm ghcr.io/ks6088ts/template-rust:latest greet
```

- The builder uses `rust:<version>-trixie` with BuildKit cache mounts. The
  runtime is `gcr.io/distroless/cc-debian13:nonroot`, which has no shell or
  package manager and runs as a non-root user. Both images are pinned by digest.
- The binary is the `ENTRYPOINT`, so arguments are passed directly, and the
  default command is `--help`.
- `.dockerignore` is an allowlist. Only the manifests, toolchain file, and
  `src/` enter the build context.
- `make docker-test` runs the image read-only with no network, no Linux
  capabilities, and `no-new-privileges`, and checks the output against
  `DOCKER_EXPECTED_OUTPUT`.
- The local image name is the lowercase directory name, tagged with the latest
  Git tag (without `v`) or the commit ID. Override with `DOCKER_IMAGE_NAME`,
  `DOCKER_REPO_NAME`, or `GIT_TAG`.

## CI/CD

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| [`ci.yaml`](.github/workflows/ci.yaml) | push to `main`, PRs | lint (fmt, Clippy, docs, typos, machete, actionlint, zizmor), release build, tests on 3 OSes, MSRV, coverage |
| [`security.yaml`](.github/workflows/security.yaml) | push, PRs, weekly | cargo-deny and Trivy repository scan |
| [`codeql.yaml`](.github/workflows/codeql.yaml) | push, PRs, weekly | CodeQL for Rust and GitHub Actions |
| [`dependency-review.yaml`](.github/workflows/dependency-review.yaml) | PRs | blocks newly added vulnerable dependencies |
| [`scorecard.yaml`](.github/workflows/scorecard.yaml) | push, weekly | OpenSSF Scorecard |
| [`docker.yaml`](.github/workflows/docker.yaml) | push, PRs, called on release | image lint, build, scan, and test; on release, multi-arch push with SBOM and provenance |
| [`release-plz.yaml`](.github/workflows/release-plz.yaml) | push to `main` | CI gate, release PR, tag and GitHub release, then binaries and images |
| [`release.yaml`](.github/workflows/release.yaml) | called on release | builds and uploads release binaries, checksums, and attestations |

All workflows default to `permissions: {}` and grant the minimum per job. They
pin every action to a full commit SHA, check out code without persisting
credentials, and pass zizmor's audits.

### Release flow

1. Merge pull requests with [Conventional Commit](https://www.conventionalcommits.org/)
   titles into `main`.
2. `release-plz` opens or updates a **release PR** that bumps the version in
   `Cargo.toml` and updates `CHANGELOG.md`.
3. Merge the release PR. After CI passes on `main`, release-plz creates the
   `vX.Y.Z` tag and the GitHub release, then calls:
   - `release.yaml`, which attaches archives for `x86_64`/`aarch64` Linux (glibc),
     `x86_64`/`aarch64` macOS, and `x86_64` Windows, plus `SHA256SUMS` and a
     build provenance attestation.
   - `docker.yaml`, which pushes `linux/amd64` and `linux/arm64` images to
     `ghcr.io/<owner>/<repo>:X.Y.Z` (and Docker Hub when configured). Stable
     versions also get the `latest` tag. Prereleases such as `1.2.3-rc.1` do
     not.

Versions come from Git tags (`git_only = true`); nothing is published to
crates.io. Verify downloads with `sha256sum -c SHA256SUMS` and
`gh attestation verify <file> --repo <owner>/<repo>`.

### Repository settings

- **Settings → Actions → General**: enable *Allow GitHub Actions to create and
  approve pull requests* so release-plz can open release PRs.
- Optional `RELEASE_PLZ_TOKEN` secret (a fine-grained PAT or GitHub App token
  with contents and pull request write access). Pull requests and tags created
  with the default `GITHUB_TOKEN` do not trigger other workflows, so without
  this secret CI does not run on the release PR itself. The release is still
  gated on CI on `main`.
- Optional Docker Hub publishing: create a repository named after the GitHub
  repository and [an access token](https://app.docker.com/settings/personal-access-tokens/create),
  then set both secrets:

  ```shell
  gh secret set DOCKERHUB_USERNAME --body "$DOCKERHUB_USERNAME"
  gh secret set DOCKERHUB_TOKEN --body "$DOCKERHUB_TOKEN"
  ```

  Setting only one of them fails the release. Publishing to two registries is
  not atomic.
- Recommended: protect `main` and require the job checks from the `ci`,
  `security`, `codeql`, and `docker` workflows. Select their actual job/matrix
  check names in the branch rule, not the workflow names. Use squash merges
  so pull request titles become the Conventional Commit messages.
- CodeQL and Scorecard upload SARIF to code scanning, which private
  repositories need GitHub Advanced Security for.

## Using this template

1. Rename the package in `Cargo.toml` (`name`, `description`, `repository`,
   `keywords`, `categories`). Update the `template_rust` crate references in
   `src/main.rs` and doctests, the command name and `TEMPLATE_RUST_NAME` variable
   in `src/cli.rs`, and the binary-name assertions in the unit and CLI tests.
   Then update `BIN_NAME` in [`release.yaml`](.github/workflows/release.yaml),
   the binary path in [`Dockerfile`](Dockerfile), and the names in this README,
   `SECURITY.md`, `CODEOWNERS`, and the issue templates. Run `cargo check`
   without `--locked` to refresh the renamed package entry in `Cargo.lock`.
2. Replace the `greet` command with your own commands and tests, and update
   `DOCKER_COMMAND`/`DOCKER_EXPECTED_OUTPUT` in the `Makefile`.
3. Reset `CHANGELOG.md` and the version (`0.1.0`).
4. Apply the repository settings above.

## Maintenance

- Dependabot proposes weekly, grouped updates for Cargo, the Rust toolchain,
  GitHub Actions, Docker base images (version and digest), and the Dev Container.
  It waits 7 days after each upstream release before proposing it.
- When the Rust toolchain changes, keep `rust-toolchain.toml` and the builder
  image in `Dockerfile` on the same version.
- Raise `rust-version` (MSRV) deliberately, for example when a dependency
  requires it. CI reads it from `Cargo.toml`.
- Tool versions are pinned in the `Makefile` (local) and in the workflows (CI).
  Keep them in sync when you upgrade. Update the actionlint checksum together
  with its version.
- Add a license to `deny.toml` only after reviewing it, and add advisory
  exceptions to `deny.toml` only with a reason.

## License

[MIT](LICENSE)
