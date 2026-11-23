# GitYourShtuff

GitYourShtuff is a template for your dotfiles, built on the
[shtuff](https://github.com/rmayobre/shtuff) shell framework. Your home directory is a git
worktree of a bare repository, and a whitelist `.gitignore` tracks only the files you choose.

## Contents

- [Creating your own repo](templating.md): start from the template before installing
- [Installation](install.md): one-command remote install (bare repo + worktree)
- [Shell configuration](shell-config.md): aliases, functions and variables
- [Whitelisting files](whitelisting.md): track new files and directories with `dot-add`
- [Updating](updating.md): pull changes and update submodules with `dot-update`
- [Backup and restore](backup-restore.md): snapshot your dotfiles and put them back with `dot-backup` and `dot-restore`
- [Troubleshooting](troubleshooting.md): check your setup with `dot-doctor`
- [Uninstalling](uninstall.md): reverse the install with `dot-uninstall`
- [macOS](macos.md): login shells, Homebrew and script compatibility
- [Publishing the docs site](publishing.md): build and deploy this manual with GitHub Actions
- [shtuff framework](https://github.com/rmayobre/shtuff): the underlying shell library

