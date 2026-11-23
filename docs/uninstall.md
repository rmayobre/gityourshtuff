# Uninstalling

`dot-uninstall` reverses the installer: it removes the link between your home directory and the
repo. It always saves a backup first, tells you about uncommitted or unpushed work, and asks
before doing anything.

```bash
dot-uninstall                          # remove the git plumbing; your files stay as plain files
dot-uninstall --remove-files           # also delete the files the repo checked out
dot-uninstall --restore <backup>       # remove them, then put back a backup
dot-uninstall --keep-repo              # keep ~/.dotfiles.git so your history survives
dot-uninstall --yes                    # don't ask for confirmation
```

## What each mode does

| Mode | Removed | Left in place |
|------|---------|---------------|
| _(default)_ | `~/.git`, `~/.gitignore`, `~/.gitmodules`, `~/.dotfiles.git` | All your dotfiles, shtuff, the `dot-*` commands, backups |
| `--remove-files` | The above, plus every tracked file, shtuff and the `dot-*` commands | Files that aren't tracked (`~/.ssh`, documents, other tools' config), backups |
| `--restore <backup>` | Same as `--remove-files` | The same, and the files from the backup are copied back |
| `--keep-repo` | Same as the mode it's combined with, except `~/.dotfiles.git` stays | Everything the mode keeps, and your history |

Directories the removed files leave empty are cleaned up. Directories that still hold anything
else, such as your own scripts in `~/.local/bin`, stay.

In the default mode, `.local/share/shtuff/.git` is a link into `~/.dotfiles.git`, so it stops
working as a git repo once that's removed. shtuff itself still loads. Delete the directory if you
no longer want it.

## Going back to how things were

The installer moved any file it replaced to `~/.dotfiles-backup/<timestamp>/`. To put your
originals back, name that folder:

```bash
dot-uninstall --restore 20261123-100143
```

That removes the repo's files and then restores the originals. `ls ~/.dotfiles-backup` shows what
is available; the installer prints the folder name when it finishes.

## Safety checks

- A `<timestamp>-pre-uninstall` backup of your current files is saved first.
- If you have uncommitted changes, it warns that they are in the backup but not in your repo.
- Unless you pass `--keep-repo`, it checks `origin` for commits you haven't pushed, because
  removing `~/.dotfiles.git` deletes your local history. It also warns if it can't reach `origin`.
- It refuses to run unless `~/.git` is a link to a bare repo, so it won't touch an ordinary
  repository.

After an uninstall without `--restore`, the `dot-restore` command can't be used, since it needs the
repo. Copy files back by hand:

```bash
cp -R ~/.dotfiles-backup/<folder>/. ~/
```

To install again later, run the installer; with `--keep-repo` the bare repo is still there, so move
it aside or set `DOTFILES_GIT` to a different path first.
