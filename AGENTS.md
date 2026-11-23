# AGENTS.md — GitYourShtuff

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
| `.config/shell/` | `env.sh`, `aliases.sh`, `functions.sh` shared by bash and zsh; sourced from the rc files (env also from `.profile`). |
| `.gitconfig` | Placeholder identity/config. |
| `.config/` | Per-app config; whitelist each app in `.gitignore`. |
| `install.sh` | Remote-runnable installer: bare repo + worktree at `$HOME`, backs up conflicts. Keep it self-contained (runs before shtuff exists). |
| `scripts/` | Helper scripts run after install. `common.sh` loads shtuff and holds only repo-specific helpers (`repo_root`, `has_tracked_changes`, `latest_stable_tag`); source it from every script. Don't add logging or other generic utilities there; shtuff already provides them. `update.sh` pulls and updates submodules. New scripts are already allowed in `.gitignore` (`!/scripts/**`). |
| `README.md` | Install instructions (the `curl ... \| bash` one-liner). |

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
- Use shtuff functions (`info`, `warn`, `error`, `confirm`, `install`, ...) rather than reimplementing. Scripts in `scripts/` log with these, never with `echo`/`printf`; shtuff's `error` doesn't exit, so follow it with `exit 1`.
  See `.shtuff/AGENTS.md` for the API.
- Keep shell files POSIX-safe where possible (`.profile`); Bash-only in `.bashrc`.

## Portability (Linux and macOS)

Everything outside `.shtuff/` must run on macOS as well as Linux with BSD userland.
`install.sh` and the shell startup files must work on macOS's stock bash 3.2. Scripts in
`scripts/` source shtuff, so they need whatever bash shtuff requires (currently 4+; shtuff's
macOS support is tracked in the shtuff repo).

- Avoid bash 4+ features (`mapfile`, `declare -A`, `${var,,}`, `&>>`).
- Avoid GNU-only flags: `sed -i` without a suffix argument, `readlink -f`, `sort -V`,
  `date -d`, `grep -P`, `xargs -r`. Prefer git's own options (e.g. `--sort=-v:refname`).
- Login shells matter on macOS: keep `.bash_profile` and `.zprofile` as thin hand-offs to
  `.profile` and `.config/shell/env.sh`.
- Don't assume a package manager. shtuff's own macOS support is handled in the shtuff repo.

## Keeping docs in sync

The `docs` branch is the user manual. Any change on `main` that affects user-facing
behavior (shell files, `.config/` layout, `.gitignore` rules, install steps, shtuff
version) needs a matching change on `docs`.

- Make the docs change on `docs` in a temporary worktree
  (`git worktree add <tmp>/docs docs`), so the `main` checkout is undisturbed.
- When a PR is requested for the `main` change, open a second PR from the docs change
  into `docs` (base `docs`, not `main`). Push the docs change to a branch first; never
  push directly to `docs` when a PR is expected.
- **Link the PRs in both descriptions**: the `main` PR body says
  `Docs: <link or #number of docs PR>`, and the docs PR body says
  `Code: <link or #number of main PR>`. Create the first PR, then create the second
  with the link, then edit the first to add the second's link.
- Keep the two PRs in step: if review feedback changes one, check whether the other
  needs updating. Merge them together.
- Skip the docs PR only when the change has no user-facing effect, and say so in the
  `main` PR description.

## Do / don't

- Do keep files small, commented, and easy to replace with a user's own.
- Do update `README.md` when install steps change.
- Don't add install scripts that touch the system without a clear need.
- Don't create pull requests or commit unless asked. When asked for a PR on `main`, the docs PR is part of that request (see above).
