# Updating

`gys-update` pulls your latest dotfiles and keeps submodules in step. It lives in
`~/.local/bin`, which is on your `PATH` once `env.sh` has loaded, so open a new shell after
installing and run it from anywhere.

```bash
gys-update                     # pull, then sync submodules to the pinned commits
gys-update --latest            # also move submodules to their newest stable release tag
gys-update --latest --commit   # ...and commit the bump
```

## What it does

1. Stops if you have uncommitted changes to tracked files, so a pull can't clobber them.
   Commit or stash first.
2. Pulls the current branch from `origin` (fast-forward only), with a progress spinner.
3. Syncs submodules to the commits your repo pins, initializing any that are missing.
4. With `--latest`, fetches tags in each submodule and checks out the newest stable release
   tag (`vX.Y.Z`; betas and release candidates are ignored). The change is staged.
5. With `--commit` as well, commits the staged bump. Run `git push` afterwards to publish it.

## Options

| Option | Effect |
|--------|--------|
| _(none)_ | Pull and sync submodules to the pinned commits |
| `--latest` | Move each submodule to its newest stable release tag and stage the change |
| `--commit` | With `--latest`, commit the staged bump (error without `--latest`) |
| `-h`, `--help` | Show usage |

## Notes

- The shtuff submodule is pinned to a release tag, not `main`. Updating it is a deliberate
  step, so review the release notes before you commit a bump.
- A fast-forward pull fails if your local branch has diverged from `origin`. Resolve that with
  `git pull --rebase` or a merge, then run the script again.
## Where things live

| Path | Holds |
|------|-------|
| `~/.local/bin/` | Commands, prefixed `gys-` so they don't clash with shtuff functions such as `update` and `install` |
| `~/.local/share/gityourshtuff/common.sh` | Shared setup that every command sources |
| `~/.local/share/shtuff/` | The shtuff framework (git submodule, pinned to a release tag) |

Everything else under `~/.local` is ignored by the whitelist `.gitignore`, so other tools' data
stays out of your repo.

## Writing your own commands

- Put new commands in `~/.local/bin/` with a `gys-` prefix, and make them executable. The
  whitelist already allows everything in that directory.
- Source the shared helpers at the top of each command:

  ```bash
  source "$(dirname "${BASH_SOURCE[0]}")/../share/gityourshtuff/common.sh"
  ```

- `common.sh` loads [shtuff](https://github.com/rmayobre/shtuff). Log with its `info`, `warn` and
  `error` functions, and show progress for network steps with its `monitor` spinner through
  `run_monitored`. `common.sh` adds only helpers specific to this repo (`repo_root`,
  `has_tracked_changes`, `latest_stable_tag`, `run_monitored`).
- shtuff's `error` doesn't exit, so follow it with `exit 1`.
- If the shtuff submodule is missing, commands tell you to run `git submodule update --init`.
- The only files that don't use shtuff are the installer (it runs before shtuff is on the
  machine) and the shell files that login shells read (`.profile`, `.zprofile`,
  `.config/shell/env.sh`).
