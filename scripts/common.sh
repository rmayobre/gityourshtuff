#!/usr/bin/env bash
# Shared setup and git helpers for scripts in this directory. Source it; don't execute it.
#   source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
#
# Logging and other general-purpose utilities come from shtuff (info, warn, error, confirm,
# ...); this file only loads it and adds helpers specific to this dotfiles repo.

# repo_root: the top-level directory of the dotfiles checkout (the parent of scripts/).
repo_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

# Load shtuff from the submodule. Plain printf here because shtuff isn't available yet.
_shtuff="$(repo_root)/.shtuff/shtuff.sh"
if [ ! -r "$_shtuff" ]; then
    printf 'error: %s not found; run: git submodule update --init\n' "$_shtuff" >&2
    return 1 2>/dev/null || exit 1
fi
LOG_TIMESTAMP="${LOG_TIMESTAMP:-false}"   # shtuff defaults to timestamps; keep output short
# shellcheck source=/dev/null
source "$_shtuff"
unset _shtuff

# has_tracked_changes DIR: succeeds if DIR has uncommitted changes to tracked files.
has_tracked_changes() {
    ! git -C "$1" diff --quiet HEAD -- 2>/dev/null
}

# latest_stable_tag DIR: print the newest vX.Y.Z tag in DIR (ignores -beta, -rc, etc.).
latest_stable_tag() {
    git -C "$1" tag --list 'v[0-9]*' --sort=-v:refname \
        | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1
}
