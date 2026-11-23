# ~/.zshrc -- managed by dotshtuff (note: shtuff is Bash; zsh support depends on the framework)
[ -r "$HOME/.local/share/shtuff/shtuff.sh" ] && . "$HOME/.local/share/shtuff/shtuff.sh"

for f in env aliases functions; do
    [ -r "$HOME/.config/shell/$f.sh" ] && . "$HOME/.config/shell/$f.sh"
done
unset f
