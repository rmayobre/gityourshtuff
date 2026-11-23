# Publishing the docs site

The documentation lives on an orphan `docs` branch, separate from the dotfiles on `main`. A
GitHub Actions workflow builds it with [MkDocs](https://www.mkdocs.org/) and publishes it to
GitHub Pages whenever `docs` changes.

## 1. Get the `docs` branch into your repo

GitHub's **Use this template** copies only the default branch unless you ask for more.

- **Creating a new repo:** tick **Include all branches** on the *Create a new repository
  from template* page. A fork copies all branches already.
- **Already created without it?** Add the branch from the template yourself:

```bash
git clone https://github.com/<user>/<repo>.git && cd <repo>
git remote add template https://github.com/rmayobre/gityourshtuff.git
git fetch template docs
git push origin template/docs:refs/heads/docs
```

Skip the docs site entirely if you don't want one. The dotfiles don't depend on it.

## 2. Update the site settings

On the `docs` branch, edit `mkdocs.yml` so the links point at your repo:

```yaml
site_name: My Dotfiles
site_url: https://<user>.github.io/<repo>/
repo_url: https://github.com/<user>/<repo>
edit_uri: edit/docs/docs/
```

Then replace the page content in `docs/` with your own, and adjust the `nav:` list to match.
Commit and push to `docs`.

## 3. Turn on GitHub Pages

1. In your repo, open **Settings → Pages**.
2. Under **Build and deployment**, set **Source** to **GitHub Actions**.

No branch or folder is selected here. The workflow uploads the built site itself. If you skip
this step, the deploy job fails.

## 4. Allow the `docs` branch to deploy

Open **Settings → Environments → `github-pages`**. If **Deployment branches and tags**
restricts which branches can deploy, add `docs`. The environment appears after the first
workflow run.

## 5. Run the workflow

Pushing to `docs` starts the **Docs** workflow (`.github/workflows/docs.yml`). To start it by
hand, open **Actions → Docs → Run workflow**, select the `docs` branch, and run it.

The workflow has two jobs:

| Job | What it does |
|-----|--------------|
| `build` | Checks out the branch, installs MkDocs from `requirements.txt`, runs `mkdocs build --strict` and uploads the `site/` folder |
| `deploy` | Publishes the uploaded site to GitHub Pages |

The `--strict` flag fails the build on broken links or config warnings, so fix those in the
log before retrying.

When the deploy job finishes, the site is at `https://<user>.github.io/<repo>/`. The URL also
appears in the job summary.

## Preview locally

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/mkdocs serve
```

Open <http://127.0.0.1:8000>. Pages reload as you edit. Run `mkdocs build --strict` to
check for the same errors the workflow would report.

## Working on the docs

Don't edit the docs on `main`, and don't merge `docs` into it. The two branches share no
history. Check out `docs` in a separate worktree so your home directory stays untouched:

```bash
git --git-dir="$HOME/.dotfiles.git" worktree add ~/dotfiles-docs docs
```

## Troubleshooting

- **Deploy job fails with "Pages not enabled" or a 404:** set **Source** to **GitHub Actions**
  (step 3).
- **Deploy is blocked by "branch not allowed":** add `docs` to the `github-pages`
  environment's deployment branches (step 4).
- **Build fails under `--strict`:** read the log for the broken link or missing page, fix it,
  and push again.
- **Workflow doesn't start:** it only runs on pushes to `docs`. Check that the workflow file
  exists on that branch, and that Actions are enabled under **Settings → Actions**.
- **Site loads without styling:** `site_url` doesn't match the real Pages URL. Correct it in
  `mkdocs.yml`.
