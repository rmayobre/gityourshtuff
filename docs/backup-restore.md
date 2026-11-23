# Backup and restore

`dot-backup` takes a snapshot of your current dotfiles, and `dot-restore` puts one back. Both
live in `~/.local/bin`, so they're on your `PATH` once a new shell has loaded `env.sh`.

## Back up

```bash
dot-backup                        # snapshot to ~/.dotfiles-backup/<timestamp>/
dot-backup --name before-upgrade  # add a label to the folder name
```

A backup contains:

- every tracked file, as it is on disk right now, so uncommitted edits are included
- new files that your whitelist `.gitignore` allows but you haven't committed yet
- a `MANIFEST.txt` with the date, host, branch, commit and whether you had uncommitted changes

A backup does not contain files the whitelist ignores (`~/.ssh`, `~/Documents`, other tools'
config) or files you deleted. Submodules, such as shtuff, aren't copied. The manifest records the
commit they were at, and `git submodule update --init` recovers them.

Labels may contain letters, digits, `.`, `_` and `-`.

## List and restore

```bash
dot-restore --list                # backups, newest first
dot-restore --dry-run             # show what restoring the newest backup would change
dot-restore                       # restore the newest backup (asks first)
dot-restore 20261123-100143-first # restore a specific backup
dot-restore --yes                 # skip the confirmation prompt
```

A backup can be named by its folder name in `~/.dotfiles-backup` or by a path.

`dot-restore` first shows each file that would change, marked `changed` or `new`. Files that
already match the backup are skipped, and files that aren't in the backup are left alone.

### Restoring can be undone

Before it overwrites anything, `dot-restore` saves your current state to a new backup ending in
`-pre-restore`. If the restore wasn't what you wanted, restore that one:

```bash
dot-restore --list      # find the newest -pre-restore backup
dot-restore <name>
```

### Files the installer replaced

When you install, any existing files that collide with the repo's files are moved to
`~/.dotfiles-backup/<timestamp>/`. They have no `MANIFEST.txt`, but `dot-restore` restores them
the same way, and the installer prints the exact command when it finishes.

## After a restore

Restoring puts files back; it doesn't change git history. Your restored files show up in
`git status` as ordinary changes, so commit them or discard them as you like. Submodules weren't
touched, so run `git submodule update --init` (or `dot-update`) if you need them.

## Options

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_BACKUP_DIR` | `~/.dotfiles-backup` | Where backups are stored and read from |

## Notes

- Backups are plain folders, so you can browse them or copy a single file back by hand.
- `~/.dotfiles-backup` is ignored by the whitelist `.gitignore`, so backups are never committed.
- Backups aren't pruned automatically. Delete old folders when you no longer need them.
- Like the other commands, these use shtuff, so they need the bash version shtuff requires.
