# Security Policy

## Supported versions

Only the latest release receives security fixes.

## Reporting a vulnerability

Please do **not** open a public issue for security problems. Report them
privately through
[GitHub Security Advisories](https://github.com/ks6088ts/template-rust/security/advisories/new).
Include the affected version, reproduction steps, and the impact you observed.
You can expect an initial response within a few business days.

## Supply-chain safeguards

- Dependencies are checked by `cargo-deny` (RustSec advisories, licenses,
  sources), Dependabot, and the dependency review action on pull requests.
- Source code and workflows are analyzed by CodeQL, Clippy, zizmor, and
  OpenSSF Scorecard; the repository and container image are scanned by Trivy.
- GitHub Actions are pinned to full commit SHAs, and container base images are
  pinned to digests.
- Release binaries and container images carry
  [build provenance attestations](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations).
  Verify them with:

  ```shell
  gh attestation verify template-rust-v1.2.3-x86_64-unknown-linux-gnu.tar.gz --repo ks6088ts/template-rust
  gh attestation verify oci://ghcr.io/ks6088ts/template-rust:1.2.3 --repo ks6088ts/template-rust
  ```
