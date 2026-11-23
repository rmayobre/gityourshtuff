# Whitelisting files

The repository's worktree is `$HOME`, so `.gitignore` ignores everything (`*`) and only
files you explicitly allow are tracked. This keeps the rest of your home directory out of
the repo.

## The easy way: `dot-add`

`dot-add` writes the rules for you, including every parent directory of a nested path, then
stages the result:

```bash
dot-add ~/.vimrc ~/.config/nvim   # allow and stage a file and a directory
dot-add --dry-run ~/.tmux.conf    # show the rules without changing anything
git commit -m "Track vim and nvim config"
```

- Paths can be absolute or relative to where you run it, and must be inside your home directory.
- It skips rules already in `.gitignore`, adds new ones under a `# Added by dot-add` comment, and
  checks the result with git. If git still ignores the path, it puts `.gitignore` back as it was.
- It refuses paths that look like secrets: files such as `.ssh/id_*`, `*.pem`, `*.key`, `.env` and
  `.netrc`, and any file containing a private key block or a common token format. Public keys
  (`*.pub`) are fine. Pass `--force` to override.
- It won't track `.git`, backups, the shtuff submodule, or a directory that is its own git
  repository.
- It never commits. Review with `git status` and commit when you're ready.

The sections below show what it writes, in case you'd rather edit by hand.

## Track a top-level file

Add an allow rule to `.gitignore`:

```gitignore
!/.vimrc
```

Then add and commit it:

```bash
git add .gitignore .vimrc
git commit -m "Track .vimrc"
```

## Track a directory

Git can't re-include a file whose parent directory is ignored, so re-include every level.
For `~/.config/nvim`:

```gitignore
!/.config/
/.config/*
!/.config/nvim/
!/.config/nvim/**
```

`!/.config/` allows the directory, `/.config/*` ignores its contents again, and the last two
lines allow `nvim` and everything inside it.

The `.config/shell/` directory is already whitelisted this way.

## Check a path

```bash
git check-ignore -v <path>
```

If the output shows a rule starting with `!`, the path is allowed. If it shows a rule
without `!` (such as `*`), the path is ignored. No output means no rule matched the path.
`git status` lists the file as untracked once it is allowed.

## Rules of thumb

- Never remove the leading `*` rule.
- Don't track secrets, keys or machine-specific state.
- Prefer allowing specific app directories over whole `~/.config`.
