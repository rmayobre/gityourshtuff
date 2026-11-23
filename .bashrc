# ~/.bashrc -- managed by GitYourShtuff
# shtuff is not loaded here: each dot-* command loads it itself. Run `use_shtuff` to load it
# into this shell on demand.

for f in env aliases functions; do
    [ -r "$HOME/.config/shell/$f.sh" ] && . "$HOME/.config/shell/$f.sh"
done
unset f
