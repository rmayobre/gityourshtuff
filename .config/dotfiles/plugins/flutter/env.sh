# Put the Flutter SDK (and the Dart it bundles) on PATH once it is installed.
_flutter_bin="${FLUTTER_HOME:-$HOME/.local/share/flutter}/bin"
if [ -d "$_flutter_bin" ]; then
    case ":$PATH:" in
        *":$_flutter_bin:"*) ;;
        *) export PATH="$_flutter_bin:$PATH" ;;
    esac
fi
unset _flutter_bin
