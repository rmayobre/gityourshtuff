# dotshtuff

A template for your dotfiles, built with the [shtuff](https://github.com/rmayobre/shtuff)
shell framework (included as a git submodule in `.shtuff/`).

Dotfiles are managed with a **bare repository** plus a **git worktree rooted at `$HOME`**.
Your home directory *is* the checkout, with no symlinks or copy scripts. A whitelist
`.gitignore` ensures only files you explicitly list are ever tracked.

## Use as your own

1. Click **Use this template** (or fork) on GitHub to create your own dotfiles repo.
2. Replace the placeholders (`.gitconfig`, shell files) with your own.
3. Follow the install steps below on each machine, using your repo's URL.

## Install

Set your repo URL and pick a location for the bare repo:

```bash
DOTFILES_URL=https://github.com/<you>/<your-dotfiles>.git
DOTFILES_GIT="$HOME/.dotfiles.git"
```

**1. Back up existing dotfiles** that the repo will overwrite (check the repo's file list):

```bash
mkdir -p ~/.dotfiles-backup
mv ~/.bashrc ~/.zshrc ~/.profile ~/.gitconfig ~/.dotfiles-backup/ 2>/dev/null
```

**2. Clone as a bare repo** (including submodules is done in step 4):

```bash
git clone --bare "$DOTFILES_URL" "$DOTFILES_GIT"
```

**3. Add a worktree at `$HOME`.** `git worktree add` refuses a non-empty directory, so create
the worktree elsewhere without a checkout and move its `.git` link into `$HOME`:

```bash
tmp=$(mktemp -d)
git --git-dir="$DOTFILES_GIT" worktree add --no-checkout "$tmp/wt" main
mv "$tmp/wt/.git" "$HOME/.git"
rmdir "$tmp/wt" "$tmp"
git --git-dir="$DOTFILES_GIT" worktree repair "$HOME"
```

**4. Check out the files and the shtuff submodule:**

```bash
cd ~
git config status.showUntrackedFiles no   # optional: quiet status in $HOME
git checkout -f main
git submodule update --init --recursive
```

Open a new shell. Day-to-day, `git status`, `git add`, `git commit`, and `git push` work from
anywhere inside `$HOME` that isn't another repo.

> `git checkout -f` overwrites files in `$HOME` with the repo's versions, which is why step 1
> backs them up.

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

## Updating shtuff

```bash
git submodule update --remote .shtuff
git add .shtuff && git commit -m "Update shtuff"
```

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
