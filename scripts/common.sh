#!/usr/bin/env bash
# Shared helpers for scripts in this directory. Source it; don't execute it.
#   source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

log()  { printf '==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

# repo_root: the top-level directory of the dotfiles checkout (the parent of scripts/).
repo_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

# has_tracked_changes DIR: succeeds if DIR has uncommitted changes to tracked files.
has_tracked_changes() {
    ! git -C "$1" diff --quiet HEAD -- 2>/dev/null
}

# latest_stable_tag DIR: print the newest vX.Y.Z tag in DIR (ignores -beta, -rc, etc.).
latest_stable_tag() {
    git -C "$1" tag --list 'v[0-9]*' --sort=-v:refname \
        | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1
}
