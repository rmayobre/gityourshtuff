#!/usr/bin/env bash
# GitYourShtuff installer: bare repo + git worktree rooted at $HOME.
#
# Usage (set DOTFILES_URL to your own dotfiles repo):
#   curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh \
#     | DOTFILES_URL=https://github.com/<user>/<repo>.git bash
#
# Variables:
#   DOTFILES_URL  (required) repo to clone
#   DOTFILES_GIT  bare repo location     (default: $HOME/.dotfiles.git)
#   DOTFILES_REF  branch to check out    (default: main)
#   DOTFILES_EXCLUDE  space-separated top-level repo files to keep out of $HOME
#                 (default: "README.md LICENSE AGENTS.md CLAUDE.md install.sh"; set to "" to
#                 check out everything). They stay in the repo; only the checkout skips them.
set -euo pipefail

: "${DOTFILES_URL:?Set DOTFILES_URL to your dotfiles repo URL}"
DOTFILES_GIT="${DOTFILES_GIT:-$HOME/.dotfiles.git}"
DOTFILES_REF="${DOTFILES_REF:-main}"
DOTFILES_EXCLUDE="${DOTFILES_EXCLUDE-README.md LICENSE AGENTS.md CLAUDE.md install.sh}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null || die "git is required"
# On macOS /usr/bin/git exists before the Command Line Tools do, and fails when run.
git --version >/dev/null 2>&1 || die "git is not usable; on macOS run: xcode-select --install"
# 'git worktree repair' needs git 2.30+.
git_ver="$(git --version | sed -n 's/^git version \([0-9]*\)\.\([0-9]*\).*/\1 \2/p')"
set -- $git_ver
if [ "${1:-0}" -lt 2 ] || { [ "${1:-0}" -eq 2 ] && [ "${2:-0}" -lt 30 ]; }; then
    die "git 2.30 or newer is required (found $(git --version))"
fi
[ -e "$DOTFILES_GIT" ] && die "$DOTFILES_GIT already exists; remove it or set DOTFILES_GIT"
[ -e "$HOME/.git" ] && die "$HOME/.git already exists; \$HOME is already a repository"

log "Cloning bare repo to $DOTFILES_GIT"
git clone --bare "$DOTFILES_URL" "$DOTFILES_GIT"
dot() { git --git-dir="$DOTFILES_GIT" "$@"; }

# git refuses to add a worktree in a non-empty directory ($HOME), so create it
# elsewhere without a checkout and move its .git link into place.
log "Creating worktree at $HOME"
tmp="$(mktemp -d)"
dot worktree add --no-checkout "$tmp/wt" "$DOTFILES_REF"
mv "$tmp/wt/.git" "$HOME/.git"
rmdir "$tmp/wt" "$tmp"
dot worktree repair "$HOME"

cd "$HOME"

# Keep repo-only files (README, LICENSE, ...) out of $HOME with a sparse checkout. Set before
# the checkout so they are never written.
if [ -n "$DOTFILES_EXCLUDE" ]; then
    log "Excluding from checkout: $DOTFILES_EXCLUDE"
    {
        echo "/*"
        for x in $DOTFILES_EXCLUDE; do echo "!/$x"; done
    } | git sparse-checkout set --no-cone --stdin
fi

# Back up any existing file that shares a path with a repo file, including excluded ones: a
# leftover ~/README.md would otherwise show up as a modification of the repo's README.md.
while IFS= read -r -d '' f; do
    if [ -e "$f" ] || [ -L "$f" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$f")"
        mv "$f" "$BACKUP_DIR/$f"
        log "Backed up $f"
    fi
done < <(git ls-tree -r -z --name-only HEAD)

log "Checking out $DOTFILES_REF"
git config status.showUntrackedFiles no
git checkout -f "$DOTFILES_REF"
git submodule update --init --recursive

log "Done. Open a new shell to load your dotfiles."
[ -d "$BACKUP_DIR" ] && log "Previous files saved in $BACKUP_DIR"
exit 0
