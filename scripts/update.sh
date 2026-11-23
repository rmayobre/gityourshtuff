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
        *) die "unknown option: $arg (try --help)" ;;
    esac
done
$COMMIT && ! $LATEST && die "--commit only applies together with --latest"

command -v git >/dev/null || die "git is required"
ROOT="$(repo_root)"
cd "$ROOT"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "$ROOT is not a git checkout"

has_tracked_changes "$ROOT" && die "uncommitted changes in $ROOT; commit or stash them first"

log "Pulling latest changes"
# Pull by branch name: a bare-clone install has no upstream or fetch refspec configured.
branch="$(git symbolic-ref --short -q HEAD || true)"
[ -n "$branch" ] || die "detached HEAD; check out a branch first"
git pull --ff-only origin "$branch"

log "Syncing submodules"
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
            log "$sm already at $tag"
            continue
        fi
        git -C "$sm" checkout --quiet "$tag"
        git add "$sm"
        log "$sm: ${current:-$(git -C "$sm" rev-parse --short HEAD)} -> $tag"
    done

    if git diff --cached --quiet; then
        log "Submodules already at their latest releases"
    elif $COMMIT; then
        git commit -qm "Update submodules to latest releases"
        log "Committed submodule updates (run 'git push' to publish)"
    else
        log "Submodule updates staged; commit them with: git commit -m 'Update submodules'"
    fi
fi

log "Done"
