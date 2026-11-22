# Shell configuration

Aliases, functions and environment variables are kept in `~/.config/shell/` and shared
by bash and zsh.

| File | Put here | Loaded by |
|------|----------|-----------|
| `env.sh` | `export` statements, `PATH` changes | `.profile`, `.bashrc`, `.zshrc` |
| `aliases.sh` | `alias name='command'` | `.bashrc`, `.zshrc` |
| `functions.sh` | shell functions | `.bashrc`, `.zshrc` |

## How loading works

Neither bash nor zsh reads these files by itself. `.bashrc` and `.zshrc` each source
`.shtuff/shtuff.sh`, then loop over `env`, `aliases` and `functions` and source
`~/.config/shell/<name>.sh` if it exists. `.profile` sources `env.sh` for login shells,
so variables are available before `.bashrc` runs.

Changes take effect in new shells. To apply them to the current one:

```bash
source ~/.bashrc    # bash
source ~/.zshrc     # zsh
```

## Adding your own

**Alias** (`aliases.sh`):

```sh
alias gs='git status'
```

**Function** (`functions.sh`):

```sh
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
```

**Variable** (`env.sh`):

```sh
export EDITOR=nvim
export PATH="$HOME/bin:$PATH"
```

## Keep them portable

These files are sourced by both shells, so stick to POSIX syntax. Avoid bash-only
features (`[[ ]]`, arrays, `function name {}`) and zsh-only features here. Put
shell-specific code directly in `.bashrc` or `.zshrc`.

shtuff is a Bash framework, so its functions (`info`, `warn`, `install`, ...) may not work
under zsh.

## Adding more files

`.gitignore` is a whitelist. The `.config/shell/` directory is already allowed, so new
files placed inside it are tracked once you `git add` them. For files outside it, see
[Whitelisting files](whitelisting.md).

## Troubleshooting

- **Alias not found:** open a new shell or `source` the rc file. Aliases are not expanded in
  non-interactive scripts.
- **New file not showing in `git status`:** it is ignored. Check with
  `git check-ignore -v <path>` and add a `!` rule to `.gitignore`.
- **Variable missing in GUI apps:** those read `.profile` or your session environment, not
  `.bashrc`. Put the variable in `env.sh`.
