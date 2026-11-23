# ~/.zshrc -- managed by GitYourShtuff
# shtuff isn't loaded here (it's a Bash framework); the dot-* commands load it themselves.

for f in env aliases functions; do
    [ -r "$HOME/.config/shell/$f.sh" ] && . "$HOME/.config/shell/$f.sh"
done
unset f
