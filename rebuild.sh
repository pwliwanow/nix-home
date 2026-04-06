#!/usr/bin/env bash
set -euo pipefail

nix develop --experimental-features "flakes nix-command ca-derivations" -v -c darwinInstall "$@"