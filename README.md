# GitYourShtuff

A template for your dotfiles, built with the [shtuff](https://github.com/rmayobre/shtuff)
shell framework (included as a git submodule in `.local/share/shtuff/`).

Dotfiles are managed with a **bare repository** plus a **git worktree rooted at `$HOME`**.
Your home directory *is* the checkout, with no symlinks or copy scripts. A whitelist
`.gitignore` ensures only files you explicitly list are ever tracked.

## Use as your own

1. Click **Use this template** (or fork) on GitHub to create your own dotfiles repo.
2. Replace the placeholders (`.gitconfig`, shell files) with your own and push.
3. Run the installer below on each machine, using your repo's URL.

## Install

Run this on any machine, replacing `<user>` and `<repo>` with your GitHub user and
dotfiles repo:

```bash
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh \
  | DOTFILES_URL=https://github.com/<user>/<repo>.git bash
```

The installer:

1. Clones your repo as a bare repo at `~/.dotfiles.git`.
2. Adds a git worktree rooted at `$HOME` (so your home directory *is* the checkout).
3. Moves any existing files it would overwrite to `~/.dotfiles-backup/<timestamp>/`.
4. Checks out your files and initializes the shtuff submodule. A sparse checkout keeps the repo-only
   files (`README.md`, `LICENSE`, `AGENTS.md`, `CLAUDE.md`, `install.sh`) out of your home directory.
   They stay in the repo; see `git sparse-checkout list`.

Open a new shell afterwards. Day-to-day, `git status`, `git add`, `git commit` and
`git push` work from anywhere inside `$HOME` that isn't another repo.

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_URL` | _(required)_ | Repo to clone |
| `DOTFILES_GIT` | `~/.dotfiles.git` | Bare repo location |
| `DOTFILES_REF` | `main` | Branch to check out |
| `DOTFILES_EXCLUDE` | `README.md LICENSE AGENTS.md CLAUDE.md install.sh` | Top-level repo files to keep out of `$HOME` (space-separated; empty to check out everything) |

Prefer to read it first? Download and inspect before running:

```bash
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh -o install.sh
less install.sh
DOTFILES_URL=https://github.com/<user>/<repo>.git bash install.sh
```

## macOS

The layout works on macOS as well as Linux:

- The installer checks for a working git 2.30+. If it reports git is unusable, run
  `xcode-select --install` and try again.
- Terminal.app starts login shells. `.bash_profile` and `.zprofile` hand off to `.profile` and
  `env.sh`, so your `PATH` and Homebrew (Apple Silicon or Intel) load in both bash and zsh.
- Scripts target the bash 3.2 and BSD tools that ship with macOS.

## Shell config

Aliases, functions and variables live in `.config/shell/` (`aliases.sh`, `functions.sh`, `env.sh`)
and are sourced by both `.bashrc` and `.zshrc`, so they're shared between bash and zsh.
Keep them POSIX-compatible; put shell-specific code in the rc files.

## Adding files

`.gitignore` is a whitelist: everything is ignored unless allowed. To track a new file:

```gitignore
!/.vimrc
```

For a directory, re-include each level:

```gitignore
!/.config/
/.config/*
!/.config/nvim/
!/.config/nvim/**
```

Then `git add .vimrc .gitignore && git commit`. Check with `git check-ignore -v <path>`.

## Updating

Pull your latest changes and sync the submodules with the update command (`~/.local/bin` is on your
`PATH` once `env.sh` has loaded, so open a new shell after installing):

```bash
dot-update                     # pull, then sync submodules to the pinned commits
dot-update --latest            # also move submodules to their newest stable release tag
dot-update --latest --commit   # ...and commit the bump
```

Commands live in `~/.local/bin` (prefixed `dot-`) and shared helpers in
`~/.local/share/dotfiles/`. The shtuff submodule is pinned to a release tag (not `main`). `--latest` fetches tags, checks
out the newest stable `vX.Y.Z` tag (ignoring betas) and stages the change. The script refuses
to run with uncommitted changes to tracked files.

## Backup and restore

```bash
dot-backup                        # snapshot your current dotfiles to ~/.dotfiles-backup/<timestamp>/
dot-backup --name before-upgrade  # ...with a label in the folder name
dot-restore --list                # list backups, newest first
dot-restore --dry-run             # show what restoring the newest backup would change
dot-restore [BACKUP] [--yes]      # restore a backup (default: the newest); asks first
```

`dot-backup` copies your tracked files plus any new files the whitelist allows, as they are on disk
(uncommitted edits included), and writes a `MANIFEST.txt` with the date, host, branch and commit.
Submodules are recorded by commit, not copied. `dot-restore` saves your current state to a
`-pre-restore` backup before overwriting anything, so a restore can be undone. It also restores the
files the installer backed up. Move the backup location with `DOTFILES_BACKUP_DIR`.

## Extra worktrees

Because the repo is bare, you can check out other branches elsewhere, e.g. to edit the docs:

```bash
git --git-dir="$HOME/.dotfiles.git" worktree add ~/dotfiles-docs docs
```

## Documentation

Docs live on the orphan `docs` branch (separate history) so GitHub Actions can build them.
They are not part of `main`.

## License

See [LICENSE](LICENSE).
