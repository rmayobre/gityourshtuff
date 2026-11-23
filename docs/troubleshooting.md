# Troubleshooting

## `dot-doctor`

`dot-doctor` checks your setup and tells you what needs attention. Run it first when something
looks wrong.

```bash
dot-doctor
```

Each check prints as `[info]` (fine), `[warn]` (worth fixing) or `[error]` (broken). It exits 1 if
anything is broken; warnings alone don't fail it.

| Check | What it looks at | If it complains |
|-------|------------------|-----------------|
| git | Version 2.30 or newer | Upgrade git (on macOS: `xcode-select --install` or Homebrew) |
| Worktree | `~/.git` is a link to a bare repo | Re-run the installer, or see [Installation](install.md) |
| Branch | You're on a branch, not a detached HEAD | `git switch main` (`dot-update` needs a branch) |
| `origin` | A remote exists and isn't the template | Create your own repo ([Creating your own repo](templating.md)), then `git remote set-url origin <url>` |
| `.gitignore` | The first rule is `*` | Restore it: the whitelist is what keeps the rest of `~` out of git |
| shtuff | The submodule is present and on a release tag | `git submodule update --init`, or `dot-update --latest` |
| `PATH` | `~/.local/bin` is on it in this shell | Open a new shell; `env.sh` adds it |
| `.gitconfig` | No `Your Name` / `you@example.com` placeholders | Edit the file |
| Sparse checkout | Reports whether repo-only files are hidden | Informational |
| Untracked files | Files the whitelist allows but git doesn't track | `git add <file>` or `dot-add <path>` |
| Uncommitted changes | Tracked files you changed | Commit them; `dot-update` refuses to run otherwise |
| Secrets | Tracked files that look like keys or tokens | `git rm --cached <file>`, and rotate the secret if you pushed it |
| Backups | Number of backups in `~/.dotfiles-backup` | Informational |

### If a secret got committed

Removing the file from the next commit doesn't remove it from history. If it was pushed, treat the
secret as compromised: rotate it first, then rewrite history only if you need to. For future
files, `dot-add` blocks the common cases before they're staged.

## Common problems

- **`dot-update: command not found`:** `~/.local/bin` isn't on your `PATH` yet. Open a new shell,
  or run `source ~/.config/shell/env.sh`.
- **`git status` shows nothing for a new file:** the whitelist ignores it. Run `dot-add <path>`.
- **Errors loading shtuff on macOS:** shtuff needs bash 4 or newer until its macOS support lands.
  See [macOS](macos.md).
- **Something broke after a change:** restore a snapshot with `dot-restore`, see
  [Backup and restore](backup-restore.md).
