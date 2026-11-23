# Creating your own dotfiles repo

GitYourShtuff is a template. Before you install anything, make your own copy of it. The
install command clones *your* repo into your home directory and tracks your changes there,
so it must point at a repo you own.

## 1. Create your repo from the template

**On GitHub (recommended):**

1. Open the template repository, `rmayobre/gityourshtuff`.
2. Click **Use this template** → **Create a new repository**.
3. Name it (for example `dotfiles`), choose **Private** if you want your dotfiles hidden, and
   create it.

**With the GitHub CLI:**

```bash
gh repo create <repo> --template rmayobre/gityourshtuff --private --clone
```

If you don't see **Use this template**, fork the repository instead. A fork keeps a link to
the original, which lets you pull in future template updates. A template copy starts with a
clean history.

Throughout these docs, `<user>` is your GitHub username and `<repo>` is the name of the
repository you just created.

## 2. Make it yours

Clone your new repo to any scratch location (not your home directory) and edit it:

```bash
git clone https://github.com/<user>/<repo>.git
cd <repo>
```

Then:

- **`.gitconfig`:** replace the placeholder name and email with your own.
- **`.bashrc`, `.zshrc`, `.profile`:** keep, trim, or extend them. They source the shtuff
  framework and your shell config.
- **`.config/shell/`:** add your aliases, functions and variables. See
  [Shell configuration](shell-config.md).
- **Other dotfiles:** copy them into the repo at the same relative path they have in your
  home directory, and allow them in `.gitignore`. See [Whitelisting files](whitelisting.md).
- **`README.md`:** replace the template's README with notes about your own setup.
- **Secrets:** don't commit keys, tokens or machine-specific files. The whitelist
  `.gitignore` helps, but check `git status` before you commit.

Commit and push:

```bash
git add -A
git commit -m "Personalize dotfiles"
git push
```

## 3. Install it

Follow [Installation](install.md) with your repo's URL. The installer clones your repo as a
bare repo, creates the worktree at `$HOME`, and checks out your files.

If your repo is private, the machine you install on needs access to it. Use an SSH URL
(`git@github.com:<user>/<repo>.git`) with a key added to your GitHub account, or log in
with the GitHub CLI. The `curl` command in the installer also needs to reach
`install.sh`: raw URLs of private repos return 404 without a token, so for a private repo
download the script with the GitHub CLI or clone it first, then run it:

```bash
gh api repos/<user>/<repo>/contents/install.sh -H "Accept: application/vnd.github.raw" > install.sh
DOTFILES_URL=git@github.com:<user>/<repo>.git bash install.sh
```

## 4. Publish the docs (optional)

To host this manual for your own repo, see [Publishing the docs site](publishing.md).

## 5. Keep it up to date

Edit files in your home directory as usual and commit from there. Pull changes and bump the
shtuff submodule to its newest release with the update script; see [Updating](updating.md):

```bash
dot-update --latest
```
