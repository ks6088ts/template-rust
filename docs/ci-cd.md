# CI/CD

## Workflows

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| [`ci.yaml`](../.github/workflows/ci.yaml) | push to `main`, PRs | lint (fmt, Clippy, docs, typos, machete, actionlint, zizmor), release build, tests on 3 OSes, MSRV, coverage |
| [`security.yaml`](../.github/workflows/security.yaml) | push, PRs, weekly | cargo-deny and Trivy repository scan |
| [`codeql.yaml`](../.github/workflows/codeql.yaml) | push, PRs, weekly | CodeQL for Rust and GitHub Actions |
| [`dependency-review.yaml`](../.github/workflows/dependency-review.yaml) | PRs | blocks newly added vulnerable dependencies |
| [`scorecard.yaml`](../.github/workflows/scorecard.yaml) | push, weekly | OpenSSF Scorecard |
| [`docker.yaml`](../.github/workflows/docker.yaml) | push, PRs, called on release | image lint, build, scan, and test; on release, multi-arch push with SBOM and provenance |
| [`release.yaml`](../.github/workflows/release.yaml) | push of a `vX.Y.Z` tag, manual | validates the tag, builds binaries, publishes images, then publishes the GitHub release with checksums and attestations (see [Releasing](release.md)) |

All workflows default to `permissions: {}` and grant the minimum per job. They
pin every action to a full commit SHA, check out code without persisting
credentials, and pass zizmor's audits.

## Repository settings

- Recommended: a tag ruleset for `refs/tags/v*` that restricts creation to
  maintainers and blocks updates and deletion, so release tags cannot be moved.
  Also enable [immutable releases](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/immutable-releases).
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
  so pull request titles become the Conventional Commit messages, and label
  pull requests so the generated release notes are grouped.
- CodeQL and Scorecard upload SARIF to code scanning, which private
  repositories need GitHub Advanced Security for.
