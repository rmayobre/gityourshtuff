# ~/.profile -- managed by dotshtuff
# Login shells: load environment variables, then .bashrc for bash.
[ -r "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"
[ -n "$BASH_VERSION" ] && [ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"
