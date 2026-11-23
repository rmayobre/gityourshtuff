# Functions shared by bash and zsh. Keep them POSIX-compatible, or move
# shell-specific ones into ~/.bashrc / ~/.zshrc.
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# use_shtuff: load the shtuff framework into this shell on demand. It defines ~125 functions,
# among them install, update, clean, copy, move and delete, which shadow system commands of the
# same name, so it isn't loaded by default. The dot-* commands don't need this.
use_shtuff() {
    [ -n "${BASH_VERSION:-}" ] || { echo "shtuff is a Bash framework; run bash first" >&2; return 1; }
    [ -r "$HOME/.local/share/shtuff/shtuff.sh" ] || { echo "shtuff not found; run: git submodule update --init" >&2; return 1; }
    . "$HOME/.local/share/shtuff/shtuff.sh"
}
