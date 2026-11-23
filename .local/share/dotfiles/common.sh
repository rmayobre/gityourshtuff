#!/usr/bin/env bash
# Shared setup and git helpers for dotfiles commands (~/.local/bin/dot-*).
# Source it; don't execute it:
#   source "$(dirname "${BASH_SOURCE[0]}")/../share/dotfiles/common.sh"
#
# Logging and other general-purpose utilities come from shtuff (info, warn, error, confirm,
# ...); this file only loads it and adds helpers specific to this dotfiles repo.

_dot_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# repo_root: the top-level directory of the dotfiles checkout (normally $HOME).
repo_root() {
    git -C "$_dot_dir" rev-parse --show-toplevel
}

# Load shtuff from the submodule (~/.local/share/shtuff). Plain printf here because shtuff
# isn't available yet.
_shtuff="$_dot_dir/../shtuff/shtuff.sh"
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

# run_monitored MESSAGE CMD [ARGS...]: run CMD in the background under shtuff's `monitor`
# spinner. CMD's output is captured and shown with `error` only if it fails.
# Returns CMD's exit status.
run_monitored() {
    local message="$1" out status
    shift
    out="$(mktemp)"
    "$@" >"$out" 2>&1 &
    monitor $! --message "$message" --success_msg "$message: done" --error_msg "$message: failed" \
        && status=0 || status=$?
    if [ "$status" -ne 0 ] && [ -s "$out" ]; then
        error "$(cat "$out")"
    fi
    rm -f "$out"
    return "$status"
}

# backup_root: where backups live (override with DOTFILES_BACKUP_DIR). The installer also
# stores the files it replaces here.
backup_root() {
    printf '%s\n' "${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup}"
}

# list_dotfiles OUTFILE: write the NUL-separated paths that make up your current dotfiles
# state: tracked files plus new files the whitelist allows, as they are on disk now (so
# uncommitted edits count). Skips deleted and sparse-excluded files, and submodules, which
# are recorded by commit in the manifest instead.
list_dotfiles() {
    local root path
    root="$(repo_root)"
    : >"$1"
    while IFS= read -r -d '' path; do
        { [ -e "$root/$path" ] || [ -L "$root/$path" ]; } || continue
        [ -d "$root/$path" ] && [ -e "$root/$path/.git" ] && continue
        printf '%s\0' "$path" >>"$1"
    done < <(git -C "$root" ls-files -z --cached --others --exclude-standard)
}

# snapshot_dotfiles DEST: copy the files from list_dotfiles into DEST, keeping paths and
# permissions, and write DEST/MANIFEST.txt describing the state. Uses a tar pipe, which
# behaves the same with GNU and BSD tar.
snapshot_dotfiles() {
    local dest="$1" root list
    root="$(repo_root)"
    list="$(mktemp)"
    list_dotfiles "$list"
    mkdir -p "$dest"
    tar -C "$root" --null -T "$list" -cf - | tar -C "$dest" -xf -
    {
        echo "created:    $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "host:       $(uname -n) ($(uname -s))"
        echo "root:       $root"
        echo "branch:     $(git -C "$root" symbolic-ref --short -q HEAD || echo '(detached)')"
        echo "commit:     $(git -C "$root" rev-parse HEAD 2>/dev/null || echo '(none)')"
        if has_tracked_changes "$root"; then echo "uncommitted: yes"; else echo "uncommitted: no"; fi
        echo "files:      $(tr -cd '\0' <"$list" | wc -c | tr -d ' ')"
        echo "submodules:"
        git -C "$root" submodule status 2>/dev/null | sed 's/^/  /'
    } >"$dest/MANIFEST.txt"
    rm -f "$list"
}
