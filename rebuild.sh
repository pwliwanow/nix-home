#!/usr/bin/env bash
set -euo pipefail

nix develop --experimental-features "flakes nix-command" -v -c darwinInstall "$@"