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
4. Checks out your files and initializes the shtuff submodule.

Open a new shell afterwards.

## Options

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_URL` | _(required)_ | Repo to clone |
| `DOTFILES_GIT` | `~/.dotfiles.git` | Bare repo location |
| `DOTFILES_REF` | `main` | Branch to check out |

## Inspect before running

```bash
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh -o install.sh
less install.sh
DOTFILES_URL=https://github.com/<user>/<repo>.git bash install.sh
```

## Troubleshooting

- **`~/.dotfiles.git already exists`:** a previous install ran. Remove it, or set
  `DOTFILES_GIT` to another path.
- **`~/.git already exists`:** `$HOME` is already a repository; the installer won't overwrite it.
- **Restoring old files:** copy them back from `~/.dotfiles-backup/<timestamp>/`.
