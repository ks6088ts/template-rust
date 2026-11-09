# ---
# Settings
# ---

MSRV ?= $(shell sed -n 's/^rust-version *= *"\(.*\)"/\1/p' Cargo.toml)
# Release version without the `v` prefix, e.g. `make release-tag VERSION=1.2.3`.
VERSION ?=
SEMVER_REGEX := ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?$$
CARGO_FLAGS ?= --workspace --all-features --locked
NEXTEST_PROFILE ?= default
COVERAGE_MIN_LINES ?= 80
ARGS ?= --help
# Online audits need GH_TOKEN; CI clears this flag.
ZIZMOR_FLAGS ?= --offline

# Tool versions. Keep in sync with `.github/workflows/*.yaml`.
CARGO_DENY_VERSION ?= 0.20.2
CARGO_LLVM_COV_VERSION ?= 0.9.1
CARGO_MACHETE_VERSION ?= 0.9.2
CARGO_NEXTEST_VERSION ?= 0.9.151
TYPOS_VERSION ?= 1.52.0
ZIZMOR_VERSION ?= 1.32.0
HADOLINT_VERSION ?= 2.15.1

# Git and Docker
GIT_TAG ?= $(shell git describe --tags --abbrev=0 --always | sed 's/^v//')
RELEASE_REMOTE ?= origin
RELEASE_BRANCH ?= main
DOCKER_REPO_NAME ?=
DOCKER_IMAGE_NAME ?= $(shell basename "$(CURDIR)" | tr '[:upper:]' '[:lower:]')
DOCKER_IMAGE ?= $(if $(DOCKER_REPO_NAME),$(DOCKER_REPO_NAME)/)$(DOCKER_IMAGE_NAME):$(GIT_TAG)
DOCKER_COMMAND ?= greet
DOCKER_EXPECTED_OUTPUT ?= Hello, World!
DOCKER_RUN_FLAGS ?= --rm --network none --read-only --cap-drop ALL --security-opt no-new-privileges

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

# ---
# Development
# ---

.PHONY: install-tools
install-tools: ## install pinned Cargo-based development tools
	cargo install --locked \
		cargo-deny@$(CARGO_DENY_VERSION) \
		cargo-llvm-cov@$(CARGO_LLVM_COV_VERSION) \
		cargo-machete@$(CARGO_MACHETE_VERSION) \
		cargo-nextest@$(CARGO_NEXTEST_VERSION) \
		typos-cli@$(TYPOS_VERSION) \
		zizmor@$(ZIZMOR_VERSION)

.PHONY: run
run: ## run the CLI (override arguments with ARGS="greet --name Rust")
	cargo run --locked -- $(ARGS)

.PHONY: build
build: ## build release binary
	cargo build $(CARGO_FLAGS) --release

.PHONY: format
format: ## format code
	cargo fmt --all

.PHONY: fix
fix: ## apply compiler and Clippy suggestions
	cargo clippy $(CARGO_FLAGS) --all-targets --fix --allow-dirty --allow-staged
	cargo fmt --all

.PHONY: update
update: ## update dependencies within Cargo.toml constraints
	cargo update

# ---
# Static analysis
# ---

.PHONY: format-check
format-check: ## check formatting
	cargo fmt --all -- --check

.PHONY: lint
lint: ## run Clippy on all targets and fail on warnings
	cargo clippy $(CARGO_FLAGS) --all-targets -- -D warnings

.PHONY: doc-check
doc-check: ## build documentation and fail on warnings
	RUSTDOCFLAGS="$(RUSTDOCFLAGS) -D warnings" cargo doc $(CARGO_FLAGS) --no-deps

.PHONY: spell
spell: ## check spelling (requires typos)
	typos

.PHONY: machete
machete: ## detect unused dependencies (requires cargo-machete)
	cargo machete

.PHONY: deny
deny: ## check advisories, licenses, bans, and sources (requires cargo-deny)
	cargo deny --locked check

.PHONY: lint-workflows
lint-workflows: ## lint GitHub Actions workflows (requires actionlint and zizmor)
	actionlint
	zizmor $(ZIZMOR_FLAGS) .github

.PHONY: scan-fs
scan-fs: ## scan the repository for vulnerabilities, secrets, and misconfigurations (requires trivy)
	trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --ignore-unfixed \
		--skip-dirs target --exit-code 1 .

.PHONY: check
check: format-check lint doc-check spell machete deny ## run all static checks

# ---
# Tests
# ---

.PHONY: test
test: ## run unit, integration, and doc tests (requires cargo-nextest)
	cargo nextest run $(CARGO_FLAGS) --profile $(NEXTEST_PROFILE)
	cargo test $(CARGO_FLAGS) --doc

.PHONY: install-msrv
install-msrv: ## install the minimum supported Rust toolchain from Cargo.toml
	rustup toolchain install $(MSRV) --profile minimal

.PHONY: test-msrv
test-msrv: ## run tests with the minimum supported Rust version from Cargo.toml
	cargo +$(MSRV) test $(CARGO_FLAGS)

.PHONY: coverage
coverage: ## measure line coverage and write lcov.info (requires cargo-llvm-cov)
	cargo llvm-cov nextest $(CARGO_FLAGS) --profile $(NEXTEST_PROFILE) \
		--lcov --output-path lcov.info --fail-under-lines $(COVERAGE_MIN_LINES)
	cargo llvm-cov report --summary-only

.PHONY: coverage-html
coverage-html: ## open an HTML coverage report (requires cargo-llvm-cov)
	cargo llvm-cov nextest $(CARGO_FLAGS) --open

.PHONY: ci-test
ci-test: check test build ## run all Rust CI checks

# ---
# Docker
# ---

.PHONY: docker-build
docker-build: ## build Docker image
	docker build -t "$(DOCKER_IMAGE)" .

.PHONY: docker-run
docker-run: ## run Docker container (override arguments with DOCKER_COMMAND)
	docker run $(DOCKER_RUN_FLAGS) "$(DOCKER_IMAGE)" $(DOCKER_COMMAND)

.PHONY: docker-test
docker-test: ## verify the image runs with restricted runtime permissions
	docker run $(DOCKER_RUN_FLAGS) "$(DOCKER_IMAGE)" --version
	@output=$$(docker run $(DOCKER_RUN_FLAGS) "$(DOCKER_IMAGE)" $(DOCKER_COMMAND)) || exit $$?; \
	if [ "$$output" != "$(DOCKER_EXPECTED_OUTPUT)" ]; then \
		printf 'Unexpected container output: %s\n' "$$output" >&2; \
		exit 1; \
	fi

.PHONY: docker-lint
docker-lint: ## lint Dockerfile
	@if docker info >/dev/null 2>&1; then \
		docker run --rm -i hadolint/hadolint:v$(HADOLINT_VERSION)-alpine < Dockerfile; \
	elif command -v hadolint >/dev/null 2>&1; then \
		echo "Docker unavailable; using local hadolint" >&2; \
		hadolint Dockerfile; \
	else \
		echo "Docker or hadolint is required to lint Dockerfile" >&2; \
		exit 1; \
	fi

.PHONY: docker-scan
docker-scan: ## fail on fixable HIGH/CRITICAL image vulnerabilities (requires trivy)
	trivy image --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 "$(DOCKER_IMAGE)"

.PHONY: ci-test-docker
ci-test-docker: ## run Docker CI checks in order, even with parallel make
	$(MAKE) docker-lint
	$(MAKE) docker-build
	$(MAKE) docker-scan
	$(MAKE) docker-test

# ---
# Release
# ---

.PHONY: check-version
check-version:
	@if ! printf '%s\n' "$(VERSION)" | grep -Eq '$(SEMVER_REGEX)'; then \
		echo "Set VERSION to a SemVer version without 'v', e.g. VERSION=1.2.3 or VERSION=1.2.3-rc.1." >&2; exit 1; \
	fi

.PHONY: set-version
set-version: check-version ## write VERSION into Cargo.toml and Cargo.lock (used by release builds)
	bash scripts/set-version.sh "$(VERSION)"

.PHONY: release-tag
release-tag: check-version ## push tag vVERSION from an up-to-date main to start a release (VERSION=1.2.3)
	@set -eu; \
	tag="v$(VERSION)"; \
	branch=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$branch" != "$(RELEASE_BRANCH)" ]; then \
		echo "Switch to $(RELEASE_BRANCH) first (current branch: $$branch)." >&2; exit 1; \
	fi; \
	if [ -n "$$(git status --porcelain)" ]; then \
		echo "Commit or stash local changes first." >&2; exit 1; \
	fi; \
	git fetch --quiet --tags $(RELEASE_REMOTE); \
	if [ "$$(git rev-parse HEAD)" != "$$(git rev-parse $(RELEASE_REMOTE)/$(RELEASE_BRANCH))" ]; then \
		echo "Local $(RELEASE_BRANCH) differs from $(RELEASE_REMOTE)/$(RELEASE_BRANCH); pull or push first." >&2; exit 1; \
	fi; \
	if git rev-parse --quiet --verify "refs/tags/$$tag" >/dev/null; then \
		echo "Tag $$tag already exists; choose a new VERSION." >&2; exit 1; \
	fi; \
	git tag --annotate "$$tag" --message "$$tag"; \
	git push $(RELEASE_REMOTE) "$$tag"; \
	echo "Pushed $$tag; follow the release workflow in GitHub Actions."
