# Environment variables shared by bash and zsh. Sourced from .profile, .zprofile and the rc files.

# Homebrew (macOS: Apple Silicon /opt/homebrew, Intel /usr/local; Linuxbrew too). No-op if absent.
# Skipped when already loaded (HOMEBREW_PREFIX is set by `brew shellenv`).
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [ -z "${HOMEBREW_PREFIX:-}" ] && [ -x "$_brew" ]; then
        eval "$("$_brew" shellenv)"
        break
    fi
done
unset _brew

export EDITOR="${EDITOR:-vi}"

# Personal scripts first, without duplicating the entry when this file is sourced twice.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
