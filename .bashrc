# ~/.bashrc -- managed by dotshtuff
[ -r "$HOME/.shtuff/shtuff.sh" ] && . "$HOME/.shtuff/shtuff.sh"

for f in env aliases functions; do
    [ -r "$HOME/.config/shell/$f.sh" ] && . "$HOME/.config/shell/$f.sh"
done
unset f
