#!/usr/bin/env bash
# Update your dotfiles and their submodules.
#
# Usage: scripts/update.sh [--latest] [--commit]
#
#   (no flags)  Pull your repo's latest changes, then sync submodules to the
#               commits your repo pins.
#   --latest    Also move each submodule to its newest stable release tag
#               (vX.Y.Z, ignoring betas) and stage the change.
#   --commit    With --latest, commit the staged submodule bumps.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

LATEST=false
COMMIT=false
for arg in "$@"; do
    case "$arg" in
        --latest) LATEST=true ;;
        --commit) COMMIT=true ;;
        -h|--help) sed -n '2,11p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) error "unknown option: $arg (try --help)"; exit 1 ;;
    esac
done
$COMMIT && ! $LATEST && { error "--commit only applies together with --latest"; exit 1; }

command -v git >/dev/null || { error "git is required"; exit 1; }
ROOT="$(repo_root)"
cd "$ROOT"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { error "$ROOT is not a git checkout"; exit 1; }

if has_tracked_changes "$ROOT"; then
    error "uncommitted changes in $ROOT; commit or stash them first"
    exit 1
fi

info "Pulling latest changes"
# Pull by branch name: a bare-clone install has no upstream or fetch refspec configured.
branch="$(git symbolic-ref --short -q HEAD || true)"
[ -n "$branch" ] || { error "detached HEAD; check out a branch first"; exit 1; }
git pull --ff-only origin "$branch"

info "Syncing submodules"
git submodule sync --recursive >/dev/null
git submodule update --init --recursive

if $LATEST; then
    git submodule foreach --quiet 'echo "$sm_path"' | while IFS= read -r sm; do
        [ -n "$sm" ] || continue
        git -C "$sm" fetch --quiet --tags origin
        tag="$(latest_stable_tag "$sm")"
        if [ -z "$tag" ]; then
            warn "$sm: no stable release tags found; leaving it as is"
            continue
        fi
        current="$(git -C "$sm" describe --tags --exact-match 2>/dev/null || true)"
        if [ "$current" = "$tag" ]; then
            info "$sm already at $tag"
            continue
        fi
        git -C "$sm" checkout --quiet "$tag"
        git add "$sm"
        info "$sm: ${current:-$(git -C "$sm" rev-parse --short HEAD)} -> $tag"
    done

    if git diff --cached --quiet; then
        info "Submodules already at their latest releases"
    elif $COMMIT; then
        git commit -qm "Update submodules to latest releases"
        info "Committed submodule updates (run 'git push' to publish)"
    else
        info "Submodule updates staged; commit them with: git commit -m 'Update submodules'"
    fi
fi

info "Done"
