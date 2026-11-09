#!/usr/bin/env bash
# Writes a release version into Cargo.toml and Cargo.lock, so release builds
# report the version of the pushed tag. Usage: scripts/set-version.sh 1.2.3
set -euo pipefail

version="${1:-}"
semver='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?$'
if [[ ! "$version" =~ $semver ]]; then
  echo "Usage: $0 <version>, e.g. 1.2.3 or 1.2.3-rc.1 (without 'v')." >&2
  exit 1
fi

cd "$(dirname "$0")/.."
name=$(sed -n 's/^name *= *"\(.*\)"/\1/p' Cargo.toml | head -n 1)

awk -v v="$version" '
  /^\[/ { pkg = ($0 == "[package]") }
  pkg && !done && /^version *=/ { $0 = "version = \"" v "\""; done = 1 }
  1' Cargo.toml > Cargo.toml.tmp
mv Cargo.toml.tmp Cargo.toml

awk -v n="$name" -v v="$version" '
  hit && /^version = / { $0 = "version = \"" v "\"" }
  { hit = ($0 == "name = \"" n "\"") }
  1' Cargo.lock > Cargo.lock.tmp
mv Cargo.lock.tmp Cargo.lock

grep -Fqx "version = \"$version\"" Cargo.toml
grep -A1 -Fx "name = \"$name\"" Cargo.lock | grep -Fqx "version = \"$version\""
echo "Set $name version to $version."
