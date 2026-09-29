# Git and Docker
GIT_TAG ?= $(shell git describe --tags --abbrev=0 --always | sed 's/^v//')
DOCKER_REPO_NAME ?=
DOCKER_IMAGE_NAME ?= $(shell basename "$(CURDIR)" | tr '[:upper:]' '[:lower:]')
DOCKER_IMAGE ?= $(if $(DOCKER_REPO_NAME),$(DOCKER_REPO_NAME)/)$(DOCKER_IMAGE_NAME):$(GIT_TAG)
DOCKER_COMMAND ?=
HADOLINT_VERSION ?= 2.15.1

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

.PHONY: format-check
format-check: ## format check
	cargo fmt --all -- --check

.PHONY: format
format: ## format code
	cargo fmt --all

.PHONY: lint
lint: ## lint all Rust targets and fail on warnings
	cargo clippy --workspace --all-targets --all-features --locked -- -D warnings

.PHONY: lint-workflows
lint-workflows: ## lint GitHub Actions workflows (requires actionlint)
	@command -v actionlint >/dev/null 2>&1 || { echo "actionlint is required: https://github.com/rhysd/actionlint#installation" >&2; exit 1; }
	actionlint

.PHONY: test
test: ## run tests
	cargo test --workspace --all-features --locked

.PHONY: test-release
test-release: ## run tests in release mode
	cargo test --workspace --all-features --release --locked

.PHONY: test-msrv
test-msrv: ## run tests with the minimum supported Rust version
	cargo +1.85.0 test --workspace --all-features --locked

.PHONY: build
build: ## build applications
	cargo build --workspace --all-features --release --locked

.PHONY: ci-test
ci-test: format-check lint test test-release build ## run Rust CI checks

.PHONY: run
run: ## run application
	cargo run --locked

.PHONY: fix
fix: ## fix code
	cargo fix

.PHONY: update
update: ## update
	cargo update

# ---
# Docker
# ---

.PHONY: docker-build
docker-build: ## build Docker image
	docker build \
		-t $(DOCKER_IMAGE) \
		.

.PHONY: docker-run
docker-run: ## run Docker container
	docker run --rm $(DOCKER_IMAGE) $(DOCKER_COMMAND)

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
docker-scan: ## fail on fixable high/critical Docker image vulnerabilities
	@command -v trivy >/dev/null 2>&1 || { echo "trivy is required: https://trivy.dev/latest/getting-started/installation/" >&2; exit 1; }
	trivy image --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 $(DOCKER_IMAGE)

.PHONY: ci-test-docker
ci-test-docker: docker-lint docker-build docker-scan docker-run ## run CI test for Docker
