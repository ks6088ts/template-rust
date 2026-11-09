# Releasing

## Release flow

1. Merge the changes to release into `main` (CI must pass).
2. On the updated `main`, run `make release-tag VERSION=X.Y.Z`. It creates an
   annotated `vX.Y.Z` tag and pushes it. Pushing a tag by hand
   (`git tag vX.Y.Z && git push origin vX.Y.Z`) works the same way.
3. The tag push starts [`release.yaml`](../.github/workflows/release.yaml):
   - `prepare` rejects tags that are not SemVer or that point to a commit
     outside `main` (so only commits that passed the required checks on `main`
     are released). Tags with a suffix such as `v1.2.3-rc.1` become prereleases.
   - `build` writes the tag's version into `Cargo.toml` and `Cargo.lock`
     ([`scripts/set-version.sh`](../scripts/set-version.sh)), so `--version`
     matches the tag, then creates archives for `x86_64`/`aarch64` Linux
     (glibc), `x86_64`/`aarch64` macOS, and `x86_64` Windows, and runs
     `--version` on the binaries the runner can execute.
   - `docker` calls [`docker.yaml`](../.github/workflows/docker.yaml), which
     builds with the same version and pushes `linux/amd64` and `linux/arm64`
     images to `ghcr.io/<owner>/<repo>:X.Y.Z` (and Docker Hub when configured).
     Stable versions also get the `latest` tag. Prereleases do not.
   - `publish` adds `SHA256SUMS` and a build provenance attestation, uploads
     everything to a **draft** release with
     [generated release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes)
     (categorized by pull request label in [`.github/release.yml`](../.github/release.yml)),
     and publishes it only after all assets are attached.

See [CONTRIBUTING.md](../CONTRIBUTING.md#releasing) for choosing the next
version, and [CI/CD](ci-cd.md#repository-settings) for the recommended tag
ruleset and optional Docker Hub secrets.

## Recovering from a failed release

If a run fails, fix the cause and re-run the failed jobs, or start the workflow
manually with the same tag (**Actions → release → Run workflow**). A leftover
draft is reused. A published release is never modified; release a new version
instead. Nothing is published to crates.io.

## Verifying downloads

```shell
sha256sum -c SHA256SUMS
gh attestation verify <file> --repo <owner>/<repo>
```
