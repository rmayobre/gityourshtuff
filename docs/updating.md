# Updating

`scripts/update.sh` pulls your latest dotfiles and keeps submodules in step. It lives in your
home directory after install, in `~/scripts/`.

```bash
~/scripts/update.sh                     # pull, then sync submodules to the pinned commits
~/scripts/update.sh --latest            # also move submodules to their newest stable release tag
~/scripts/update.sh --latest --commit   # ...and commit the bump
```

## What it does

1. Stops if you have uncommitted changes to tracked files, so a pull can't clobber them.
   Commit or stash first.
2. Pulls the current branch from `origin` (fast-forward only).
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
- Scripts in `scripts/` load [shtuff](https://github.com/rmayobre/shtuff) through
  `scripts/common.sh` and log with its `info`, `warn` and `error` functions. `common.sh` adds only
  helpers specific to this repo (`repo_root`, `has_tracked_changes`, `latest_stable_tag`). Source it
  from your own scripts, and put new helper scripts in `scripts/`. `.gitignore` already allows
  everything under `scripts/`.
- If the shtuff submodule is missing, the script tells you to run `git submodule update --init`.
