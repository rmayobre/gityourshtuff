# Functions shared by bash and zsh. Keep them POSIX-compatible, or move
# shell-specific ones into ~/.bashrc / ~/.zshrc.
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
