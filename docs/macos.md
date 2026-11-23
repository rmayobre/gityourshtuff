# macOS

The layout supports macOS and Linux. This page covers what is macOS-specific.

!!! note
    shtuff's own macOS support (for example Homebrew in its package helpers) is handled in the
    [shtuff](https://github.com/rmayobre/shtuff) project. This page covers the dotfiles layout only.

## Before you install

The installer needs a working git 2.30 or newer. macOS ships a `git` stub that fails until the
Command Line Tools are installed. If the installer says git is not usable, run:

```bash
xcode-select --install
```

then run the installer again.

## Login shells

Terminal.app starts login shells, which read different files than interactive non-login shells
on most Linux setups. The layout hands off so both shells load the same environment:

| Shell | Reads | Then |
|-------|-------|------|
| zsh (macOS default) | `.zprofile`, then `.zshrc` | `.zprofile` loads `env.sh` (PATH, Homebrew) |
| bash | `.bash_profile` (login) or `.bashrc` | `.bash_profile` loads `.profile`, which loads `env.sh` and `.bashrc` |

If you already have a `~/.bash_profile`, the installer moves it to
`~/.dotfiles-backup/<timestamp>/` before checking out yours.

## Homebrew and PATH

`~/.config/shell/env.sh` loads Homebrew when it is installed, whether it lives in
`/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel). It then adds `~/.local/bin` to `PATH`
once, even if the file is sourced more than once. Nothing happens if Homebrew isn't installed.

## Script compatibility

macOS ships bash 3.2 and BSD versions of `sed`, `date` and friends. The installer and update
scripts avoid bash 4+ features and GNU-only flags so they run unchanged. When you write your
own scripts for this layout:

- Avoid `mapfile`, `declare -A` and `${var,,}`.
- Avoid `sed -i` without a suffix, `readlink -f`, `sort -V`, `date -d`, `grep -P` and
  `xargs -r`.
- Prefer git's own options. For example, the update script sorts tags with
  `git tag --sort=-v:refname`.

## Gotchas

- **Case-insensitive filesystem:** APFS ignores case by default, so two paths that differ only
  in case collide. Avoid tracking both.
- **`.DS_Store` and `Library/`:** the whitelist `.gitignore` ignores them by default.
- **GUI app settings:** most live in `~/Library/Application Support`, not `~/.config`. You can
  track them, but each needs its own whitelist rules. See
  [Whitelisting files](whitelisting.md).
