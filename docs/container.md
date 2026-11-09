# Container image

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

Published images are built by [`docker.yaml`](../.github/workflows/docker.yaml)
during a release. See [Releasing](release.md).
