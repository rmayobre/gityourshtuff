# Whitelisting files

The repository's worktree is `$HOME`, so `.gitignore` ignores everything (`*`) and only
files you explicitly allow are tracked. This keeps the rest of your home directory out of
the repo.

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
