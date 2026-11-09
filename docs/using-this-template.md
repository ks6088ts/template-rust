# Using this template

## Starting a new project

1. Rename the package in `Cargo.toml` (`name`, `description`, `repository`,
   `keywords`, `categories`). Update the `template_rust` crate references in
   `src/main.rs` and doctests, the command name and `TEMPLATE_RUST_NAME` variable
   in `src/cli.rs`, and the binary-name assertions in the unit and CLI tests.
   Then update `BIN_NAME` in [`release.yaml`](../.github/workflows/release.yaml),
   the binary path in [`Dockerfile`](../Dockerfile), and the names in
   `README.md`, `docs/`, `SECURITY.md`, `CODEOWNERS`, and the issue templates.
   Run `cargo check` without `--locked` to refresh the renamed package entry in
   `Cargo.lock`.
2. Replace the `greet` command with your own commands and tests (see
   [Adding a subcommand](cli.md#adding-a-subcommand)), and update
   `DOCKER_COMMAND`/`DOCKER_EXPECTED_OUTPUT` in the `Makefile`.
3. Reset the version in `Cargo.toml` (`0.1.0`). Release builds replace it with
   the tag's version, so it only affects local builds.
4. Apply the [repository settings](ci-cd.md#repository-settings).

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
