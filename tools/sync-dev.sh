#!/usr/bin/env bash
# Auto-sync dev from upstream/main + re-apply patch branches.
# Usage: tools/sync-dev.sh [--dry-run|--no-push]
set -euo pipefail

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run|--no-push) DRY_RUN=1 ;;
    -h|--help)
      echo "Usage: $0 [--dry-run|--no-push]"
      exit 0
      ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
done

PATCHES=(
  "fix/x11-desktop-dpi"
)

git fetch upstream main
git fetch origin

rm -rf vendor/winit/target
 git checkout -B dev upstream/main

for patch in "${PATCHES[@]}"; do
  if git rev-parse --verify "origin/${patch}" >/dev/null 2>&1; then
    git merge --no-edit "origin/${patch}"
  else
    echo "SKIP missing origin/${patch}" >&2
  fi
done

git diff --check

if [[ "$DRY_RUN" == "1" ]]; then
  echo "DRY-RUN: skipping push" >&2
  git status --short --branch
else
  git push origin dev
fi
