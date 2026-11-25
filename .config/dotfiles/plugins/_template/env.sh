# env.sh: shell environment the plugin needs, e.g. a PATH entry. (optional)
#
# Not a hook and not executable: login shells SOURCE it at startup, from ~/.config/shell/env.sh,
# for every plugin folder that has one, enabled or not (so guard everything).
#
# Rules (it runs in every login shell, bash and zsh, and on macOS's bash 3.2)
#   Keep it POSIX sh, fast and silent. No commands that start other programs, no output, no
#   shtuff (it isn't loaded). Don't `exit`.
#   Guard on the software existing, so the file is harmless where the plugin isn't installed:
#
#     [ -d "$HOME/.local/share/flutter/bin" ] || return 0
#     case ":$PATH:" in
#         *":$HOME/.local/share/flutter/bin:"*) ;;
#         *) export PATH="$HOME/.local/share/flutter/bin:$PATH" ;;
#     esac
#
#   (`return 0` is fine here because the file is sourced, not run.)
