# AGENTS.md — dotshtuff

Guidance for AI agents working in this repository.

## What this repo is

A **template** for personal dotfiles, built on the
[shtuff](https://github.com/rmayobre/shtuff) Bash framework (git submodule at
`.shtuff/`). Users install it as a **bare repo + a git worktree whose path is
`$HOME`**, so tracked files sit at the repo root exactly where they live in `$HOME`
(`.bashrc`, `.config/...`).

Keep it minimal: templated file structure, as little scripting as possible.

## Layout

| Path | Purpose |
|------|---------|
| `.shtuff/` | shtuff framework submodule, pinned to a release tag (not `main`). Do not edit; bump by checking out a newer tag. |
| `.bashrc`, `.zshrc`, `.profile` | Shell startup files that source `.shtuff/shtuff.sh`. |
| `.gitconfig` | Placeholder identity/config. |
| `.config/` | Per-app config; whitelist each app in `.gitignore`. |
| `README.md` | Install instructions (bare repo + worktree). |

## Branches

- `main` — the dotfiles template. Worktree checked out into `$HOME`.
- `docs` — orphan branch holding documentation sources, built by GitHub Actions.
  It shares no history with `main`; never merge them. Docs changes go on `docs`.

## `.gitignore` is a whitelist — critical

The worktree is `$HOME`, so `.gitignore` starts with `*` and ignores everything.
**Any new tracked file or directory must be explicitly allowed with a `!` rule.**

- Allow a top-level file: `!/.vimrc`
- Allow a directory: re-include each level, e.g. `!/.config/`, `/.config/*`,
  then `!/.config/nvim/` and `!/.config/nvim/**`.
- Verify with `git check-ignore -v <path>` (no output for a tracked path means allowed
  only if `git status` lists it).
- Never remove the leading `*`. Never commit secrets, keys, or machine-specific state.

## shtuff conventions

- Source `shtuff.sh` locally from the submodule; do not use the remote variant in dotfiles.
- Use shtuff functions (`info`, `warn`, `error`, `install`, ...) rather than reimplementing.
  See `.shtuff/AGENTS.md` for the API.
- Keep shell files POSIX-safe where possible (`.profile`); Bash-only in `.bashrc`.

## Do / don't

- Do keep files small, commented, and easy to replace with a user's own.
- Do update `README.md` when install steps change.
- Don't add install scripts that touch the system without a clear need.
- Don't create pull requests or commit unless asked.
