# Installation

!!! warning "This repository is a template"
    `rmayobre/gityourshtuff` is a template, not a dotfiles repo you install directly. Your
    dotfiles live in your own copy of it, so create one first and use *its* URL in the
    commands below. See [Creating your own dotfiles repo](templating.md).

GitYourShtuff installs as a bare repo plus a git worktree rooted at `$HOME`, using a single
remote command. Replace `<user>` and `<repo>` with your GitHub user and dotfiles repo:

```bash
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh \
  | DOTFILES_URL=https://github.com/<user>/<repo>.git bash
```

## What it does

1. Clones your repo as a bare repo at `~/.dotfiles.git`.
2. Adds a worktree rooted at `$HOME`.
3. Moves existing files it would overwrite to `~/.dotfiles-backup/<timestamp>/`.
4. Checks out your files and initializes the shtuff submodule. A sparse checkout keeps the
   repo-only files (`README.md`, `LICENSE`, `AGENTS.md`, `CLAUDE.md`, `install.sh`) out of your
   home directory. They stay in the repo.

Open a new shell afterwards.

## Options

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_URL` | _(required)_ | Repo to clone |
| `DOTFILES_GIT` | `~/.dotfiles.git` | Bare repo location |
| `DOTFILES_REF` | `main` | Branch to check out |
| `DOTFILES_EXCLUDE` | `README.md LICENSE AGENTS.md CLAUDE.md install.sh` | Top-level repo files to keep out of `$HOME` (space-separated; empty to check out everything) |

## Inspect before running

```bash
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh -o install.sh
less install.sh
DOTFILES_URL=https://github.com/<user>/<repo>.git bash install.sh
```

## Repo-only files

The sparse checkout means your home directory doesn't get a `README.md`, `LICENSE`, `AGENTS.md`,
`CLAUDE.md` or `install.sh` at its top level. They're still in your repo, and a normal
`git pull` or commit never touches them.

```bash
git sparse-checkout list       # show the patterns in use
git show HEAD:README.md        # read an excluded file without checking it out
git sparse-checkout disable    # check out everything
```

To change what's excluded, set `DOTFILES_EXCLUDE` when you run the installer. An empty value
checks out everything. If you already have a file at one of these paths in your home directory,
such as your own `~/README.md`, the installer moves it to the backup directory so it doesn't
appear as a change to the repo's copy.

## Troubleshooting

- **`~/.dotfiles.git already exists`:** a previous install ran. Remove it, or set
  `DOTFILES_GIT` to another path.
- **`~/.git already exists`:** `$HOME` is already a repository; the installer won't overwrite it.
- **Restoring old files:** copy them back from `~/.dotfiles-backup/<timestamp>/`.
