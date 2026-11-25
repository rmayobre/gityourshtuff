# AGENTS.md — GitYourShtuff

Guidance for AI agents working in this repository.

## What this repo is

A **template** for personal dotfiles, built on the
[shtuff](https://github.com/rmayobre/shtuff) Bash framework (git submodule at
`.local/share/shtuff/`). Users install it as a **bare repo + a git worktree whose path is
`$HOME`**, so tracked files sit at the repo root exactly where they live in `$HOME`
(`.bashrc`, `.config/...`).

Keep it minimal: templated file structure, as little scripting as possible.

## Layout

| Path | Purpose |
|------|---------|
| `.local/share/shtuff/` | shtuff framework submodule, pinned to a release tag (not `main`). Do not edit; bump by checking out a newer tag. |
| `.bashrc`, `.zshrc`, `.profile` | Shell startup files. They do **not** source shtuff (it adds startup time and defines ~125 functions, such as `install` and `update`, that shadow system commands); `.config/shell/functions.sh` provides `use_shtuff` to load it on demand. |
| `.config/shell/` | `env.sh`, `aliases.sh`, `functions.sh` shared by bash and zsh; sourced from the rc files (env also from `.profile`). |
| `.gitconfig` | Placeholder identity/config (`Your Name`, `you@example.com`); `dot-init` replaces the placeholders and `dot-doctor` warns while they remain, so keep those exact strings. |
| `.config/` | Per-app config; whitelist each app in `.gitignore`. |
| `install.sh` | Remote-runnable installer: bare repo + worktree at `$HOME`, backs up conflicts. Keep it self-contained (runs before shtuff exists). A sparse checkout (`DOTFILES_EXCLUDE`) keeps repo-only root files (`README.md`, `LICENSE`, `AGENTS.md`, `CLAUDE.md`, `install.sh`) out of `$HOME`; add new repo-only root files to its default list. |
| `.local/bin/` | Commands, prefixed `dot-` so they don't clash with shtuff functions (`update`, `install`, ...). `dot-update` pulls and updates submodules; `dot-backup` and `dot-restore` snapshot and restore your dotfiles (backups in `~/.dotfiles-backup`, the same place the installer puts the files it replaces); `dot-add` writes the whitelist rules for new paths (use it instead of hand-editing nested rules); `dot-init` sets the git identity and `origin` after install (replacing `.gitconfig`'s placeholders); `dot-doctor` health-checks the setup; `dot-uninstall` reverses the installer. New commands are already allowed in `.gitignore` (`!/.local/bin/**`). |
| `.local/share/dotfiles/` | `common.sh`: loads shtuff and holds only repo-specific helpers (`repo_root`, `has_tracked_changes`, `latest_stable_tag`) plus the backup helpers (`backup_root`, `list_dotfiles`, `snapshot_dotfiles`, `restore_snapshot`), the secret checks (`is_sensitive`, `SECRET_PATTERN`) and `run_monitored`, a thin wrapper that runs a command under shtuff's `monitor` spinner. Source it from every command. `plugins.sh` (sourced by `common.sh`) is the plugin runner: `run_plugins`, `enabled_plugins`, `plugin_is_installed`. Don't add logging or other generic utilities there; shtuff already provides them. |
| `.config/dotfiles/` | Plugins. `plugins.list` (enabled, shared) and `plugins/NAME/` with one executable per hook: `installed` and `init` (required), `update`, `backup`, `restore`, and the reserved `check`, `uninstall`. `plugins/_template/` documents each hook's environment (`DOT_*`) and exit-code contract and is skipped by the runner. `plugins.local` (per-machine, git-ignored) adds or removes names. `dot-plugin` lists, creates (`new`) and runs plugins; `dot-init` runs `init` (after a confirmation), `dot-update` runs `update`, `dot-backup` runs `backup` (data lands in the snapshot's `.plugin-data/NAME/`, which the file restore skips and which is secret-scanned) and `dot-restore` runs `restore`, each in its own process, with no timeout, so a failing plugin is reported without stopping the command. An empty `needs-sudo` file makes the runner ask for the sudo password up front (hooks then use `sudo -n`); an optional `env.sh` is sourced by `.config/shell/env.sh`, so keep it POSIX, fast and guarded. Example plugins ship disabled: `flutter`, `docker`, `nvidia-drivers`. |
| `README.md` | Install instructions (the `curl ... \| bash` one-liner). |

## Branches

- `main` — the dotfiles template. Worktree checked out into `$HOME`.
- `docs` — orphan branch holding documentation sources, built by GitHub Actions.
  It shares no history with `main`; never merge them. Docs changes go on `docs`.

## `.gitignore` is a whitelist — critical

The worktree is `$HOME`, so `.gitignore` starts with `*` and ignores everything.
**Any new tracked file or directory must be explicitly allowed with a `!` rule.**

- Allow a top-level file: `!/.vimrc`
- Under `.local/`, only `bin/`, `share/dotfiles/` and `share/shtuff` are allowed; the rest
  of `.local` (other tools' data) must stay ignored.
- Allow a directory: re-include each level, e.g. `!/.config/`, `/.config/*`,
  then `!/.config/nvim/` and `!/.config/nvim/**`.
- Verify with `git check-ignore -v <path>` (no output for a tracked path means allowed
  only if `git status` lists it).
- Prefer `dot-add <path>` to hand-editing: it re-includes every parent directory and verifies the result.
- Never remove the leading `*`. Never commit secrets, keys, or machine-specific state.

## shtuff conventions

- Source `shtuff.sh` locally from the submodule; do not use the remote variant in dotfiles. Commands load it through `common.sh`; never source it from the shell startup files.
- Use shtuff functions (`info`, `warn`, `error`, `confirm`, `install`, ...) rather than reimplementing. Commands in `.local/bin/` log with these, never with `echo`/`printf`; shtuff's `error` doesn't exit, so follow it with `exit 1`.
  See `.local/share/shtuff/AGENTS.md` for the API.
- **Every command in `.local/bin/` must source `.local/share/dotfiles/common.sh` (which loads shtuff)** and use
  shtuff for logging, prompts (`confirm`, ...), file operations (`copy`, `move`, `delete`) and
  long-running or network steps (`run_monitored`, which wraps `monitor`).
- The only exceptions are `install.sh` (it runs via `curl` before the repo or shtuff exist)
  and the POSIX files sourced by login shells (`.profile`, `.zprofile`,
  `.config/shell/env.sh`), which must stay fast and shtuff-free.
- Keep shell files POSIX-safe where possible (`.profile`); Bash-only in `.bashrc`.

## Portability (Linux and macOS)

Everything outside `.local/share/shtuff/` must run on macOS as well as Linux with BSD userland.
`install.sh` and the shell startup files must work on macOS's stock bash 3.2. Commands in
`.local/bin/` source shtuff, so they need whatever bash shtuff requires (currently 4+; shtuff's
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
