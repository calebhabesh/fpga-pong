#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/work" -w /work \
  ghdl/ghdl:5.1.1-mcode-ubuntu-24.04@sha256:5f98c8192c42150ba184cd425d00372652641be33d08f75d90c955e4b0c10828 \
  bash scripts/check.sh
