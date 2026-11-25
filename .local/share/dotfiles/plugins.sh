#!/usr/bin/env bash
# Plugin runner for the dot-* commands. Sourced by common.sh; don't source it directly.
#
# A plugin is a folder in ~/.config/dotfiles/plugins/NAME/ holding one executable per hook
# (installed, init, update, ...). See ~/.config/dotfiles/plugins/_template/ for the contract.
# Every hook runs as its own process, so a plugin that crashes, exits non-zero or has a syntax
# error cannot take the calling command down. Failures are
# counted and reported; the caller decides what they mean for its own exit status. There is no
# time limit: plugins install and update packages, which can legitimately take a while.
#
# Environment you can set:
#   DOTFILES_PLUGIN_CONFIG  Config folder (default: <repo root>/.config/dotfiles).

# Hooks the dot-* commands run (check and uninstall are reserved in the template, not run yet).
# dot-plugin run only offers the first two: backup and restore need a snapshot to work on.
PLUGIN_HOOKS="init update backup restore"
PLUGIN_RUN_HOOKS="init update"

# Where plugin data lives inside a dot-backup snapshot: .plugin-data/NAME/. The file restore
# skips this folder; restore hooks read from it.
PLUGIN_DATA_DIR=".plugin-data"

# The .plugin-data folder of the snapshot being written (backup) or read (restore). Set by
# backup_plugins and by dot-restore; the backup and restore hooks get their folder from it.
PLUGIN_BACKUP_ROOT=""

# Results of the last run_plugins call.
PLUGINS_OK=0
PLUGINS_SKIPPED=0
PLUGINS_FAILED=0
PLUGINS_FAILED_LIST=""

# plugin_config_dir: folder holding plugins.list, plugins.local and plugins/.
plugin_config_dir() {
    printf '%s\n' "${DOTFILES_PLUGIN_CONFIG:-$(repo_root)/.config/dotfiles}"
}

# plugins_dir: folder holding one sub-folder per plugin.
plugins_dir() {
    printf '%s/plugins\n' "$(plugin_config_dir)"
}

# dot_os: linux, macos or other.
dot_os() {
    case "$(uname -s)" in
        Linux)  echo linux ;;
        Darwin) echo macos ;;
        *)      echo other ;;
    esac
}

# valid_plugin_name NAME: lowercase letters, digits, - and _, not starting with _ or - (the
# leading _ is reserved for the template). Also keeps names from escaping the plugins folder.
valid_plugin_name() {
    case "$1" in
        ""|[!a-z0-9]*|*[!a-z0-9_-]*) return 1 ;;
    esac
}

# enabled_plugins: print the enabled plugin names, one per line, in order. Reads plugins.list
# (committed, shared by all your machines), then plugins.local (git-ignored, this machine
# only), where "name" adds a plugin and "-name" turns one off. "#" starts a comment.
enabled_plugins() {
    local cfg file line name removed=" " out=" " order="" n
    cfg="$(plugin_config_dir)"
    for file in "$cfg/plugins.list" "$cfg/plugins.local"; do
        [ -r "$file" ] || continue
        while IFS= read -r line || [ -n "$line" ]; do
            name="${line%%#*}"
            name="${name//[[:space:]]/}"
            [ -n "$name" ] || continue
            case "$name" in
                -*) removed="$removed${name#-} " ;;
                *)  case "$out" in *" $name "*) ;; *) out="$out$name "; order="$order$name " ;; esac ;;
            esac
        done <"$file"
    done
    for n in $order; do
        case "$removed" in *" $n "*) ;; *) printf '%s\n' "$n" ;; esac
    done
}

# plugin_hook_script NAME HOOK: print the script that implements HOOK for plugin NAME and
# succeed, or fail if there is none. HOOK.linux / HOOK.macos win over the plain HOOK.
plugin_hook_script() {
    local dir f
    dir="$(plugins_dir)/$1"
    for f in "$dir/$2.$(dot_os)" "$dir/$2"; do
        if [ -f "$f" ]; then printf '%s\n' "$f"; return 0; fi
    done
    return 1
}

# _plugin_exec NAME HOOK SCRIPT: run SCRIPT in its own process with the DOT_* environment, in
# the plugin's folder, with stdin closed so it can never wait for input.
_plugin_exec() {
    local name="$1" hook="$2" script="$3" dir
    local -a extra=()
    dir="$(plugins_dir)/$name"
    case "$hook" in
        backup)  extra=(DOT_BACKUP_DEST="$PLUGIN_BACKUP_ROOT/$name") ;;
        restore) extra=(DOT_BACKUP_SRC="$PLUGIN_BACKUP_ROOT/$name") ;;
    esac
    (
        cd "$dir" || exit 1
        exec env \
            DOT_PLUGIN="$name" \
            DOT_PLUGIN_DIR="$dir" \
            DOT_HOOK="$hook" \
            DOT_OS="$(dot_os)" \
            DOT_ROOT="$(repo_root)" \
            DOT_COMMON="$_dot_dir/common.sh" \
            ${extra[@]+"${extra[@]}"} "$script" </dev/null
    )
}

# _plugin_prepare NAME: a plugin with a `needs-sudo` file in its folder installs system
# packages. Hooks run behind a spinner with no input, where a password prompt would hang
# unseen, so ask for the password here, once, before the hook starts. The hook then uses
# `sudo -n`. Returns non-zero if sudo can't be used.
_plugin_prepare() {
    [ -e "$(plugins_dir)/$1/needs-sudo" ] || return 0
    [ "$(id -u)" -ne 0 ] || return 0
    command -v sudo >/dev/null 2>&1 || { warn "$1 needs root but sudo isn't installed; run dot-init as root"; return 1; }
    sudo -n true 2>/dev/null && return 0
    info "$1 needs administrator rights"
    sudo -v || { warn "$1: sudo authentication failed"; return 1; }
}

# plugin_is_installed NAME: run the plugin's `installed` hook silently. Succeeds if installed.
plugin_is_installed() {
    local script
    script="$(plugin_hook_script "$1" installed)" || return 1
    [ -x "$script" ] || return 1
    _plugin_exec "$1" installed "$script" >/dev/null 2>&1
}

# _plugin_scan_backup NAME: after a backup hook, look through what it stored for secrets (the
# same checks dot-doctor uses). If there are any, delete the plugin's data and fail, leaving the
# offending paths in PLUGIN_SCAN_HITS. A backup must never quietly keep a credential.
PLUGIN_SCAN_HITS=""
_plugin_scan_backup() {
    local dir="$PLUGIN_BACKUP_ROOT/$1" f rel
    PLUGIN_SCAN_HITS=""
    [ -d "$dir" ] || return 0
    while IFS= read -r -d '' f; do
        rel="${f#"$dir"/}"
        if is_sensitive "$rel"; then PLUGIN_SCAN_HITS="$PLUGIN_SCAN_HITS $rel"; fi
    done < <(find "$dir" -type f -print0)
    while IFS= read -r f; do
        [ -n "$f" ] && PLUGIN_SCAN_HITS="$PLUGIN_SCAN_HITS ${f#"$dir"/}"
    done < <(grep -rIlE -e "$SECRET_PATTERN" "$dir" 2>/dev/null || true)
    [ -z "$PLUGIN_SCAN_HITS" ] && return 0
    rm -rf "${dir:?}"
    return 1
}

_plugin_ok()      { PLUGINS_OK=$((PLUGINS_OK + 1)); }
_plugin_skipped() { PLUGINS_SKIPPED=$((PLUGINS_SKIPPED + 1)); info "$1: $2"; }
_plugin_skipped_quietly() { PLUGINS_SKIPPED=$((PLUGINS_SKIPPED + 1)); }
_plugin_failed()  {
    PLUGINS_FAILED=$((PLUGINS_FAILED + 1))
    PLUGINS_FAILED_LIST="$PLUGINS_FAILED_LIST $1"
    warn "$1: $2"
}

# _run_one_plugin HOOK NAME: run HOOK for one plugin, updating the PLUGINS_* counters.
_run_one_plugin() {
    local hook="$1" name="$2" script

    if ! valid_plugin_name "$name"; then _plugin_failed "$name" "not a valid plugin name"; return 0; fi
    if [ ! -d "$(plugins_dir)/$name" ]; then _plugin_failed "$name" "no such plugin in $(plugins_dir)"; return 0; fi

    script="$(plugin_hook_script "$name" installed)" || {
        _plugin_failed "$name" "has no 'installed' script (every plugin needs one)"; return 0; }
    if [ ! -x "$script" ]; then _plugin_failed "$name" "installed is not executable (chmod +x $script)"; return 0; fi

    if plugin_is_installed "$name"; then
        if [ "$hook" = init ]; then _plugin_skipped "$name" "already installed"; return 0; fi
    else
        if [ "$hook" != init ]; then _plugin_skipped "$name" "not installed, skipping $hook"; return 0; fi
    fi

    script="$(plugin_hook_script "$name" "$hook")" || {
        if [ "$hook" = init ]; then _plugin_failed "$name" "has no 'init' script"
        else _plugin_skipped_quietly; fi   # most plugins have no update, backup or restore
        return 0; }
    if [ ! -x "$script" ]; then _plugin_failed "$name" "$hook is not executable (chmod +x $script)"; return 0; fi

    [ "$hook" != backup ] || mkdir -p "$PLUGIN_BACKUP_ROOT/$name"
    if ! _plugin_prepare "$name"; then _plugin_failed "$name" "could not get administrator rights"; return 0; fi

    if run_monitored "$name: $hook" _plugin_exec "$name" "$hook" "$script"; then
        if [ "$hook" = init ] && ! plugin_is_installed "$name"; then
            _plugin_failed "$name" "init succeeded but 'installed' still reports it missing"
        elif [ "$hook" = backup ] && ! _plugin_scan_backup "$name"; then
            _plugin_failed "$name" "backup looked like it held secrets (${PLUGIN_SCAN_HITS# }); its data was not kept"
        else
            _plugin_ok
        fi
    else
        _plugin_failed "$name" "$hook failed"
    fi
    return 0
}

# run_plugins HOOK [NAME...]: run HOOK for the named plugins, or for every enabled plugin when
# none are named. Always returns 0; read PLUGINS_FAILED afterwards.
#   init     installs plugins whose `installed` hook fails.
#   update   updates plugins whose `installed` hook succeeds.
#   backup   asks installed plugins to store data in $PLUGIN_BACKUP_ROOT/NAME (see backup_plugins).
#   restore  asks installed plugins to read $PLUGIN_BACKUP_ROOT/NAME back.
run_plugins() {
    local hook="$1" name
    local -a names=()
    shift
    PLUGINS_OK=0; PLUGINS_SKIPPED=0; PLUGINS_FAILED=0; PLUGINS_FAILED_LIST=""
    case " $PLUGIN_HOOKS " in *" $hook "*) ;; *) error "unknown plugin hook: $hook"; return 0 ;; esac

    if [ $# -gt 0 ]; then
        names=("$@")
    else
        while IFS= read -r name; do names+=("$name"); done < <(enabled_plugins)
    fi
    [ "${#names[@]}" -gt 0 ] || return 0

    for name in "${names[@]}"; do _run_one_plugin "$hook" "$name"; done

    # Quiet when nothing ran: most plugins have no backup or restore hook.
    if [ "$hook" = init ] || [ $((PLUGINS_OK + PLUGINS_FAILED)) -gt 0 ]; then
        info "Plugins ($hook): $PLUGINS_OK ok, $PLUGINS_SKIPPED skipped, $PLUGINS_FAILED failed"
    fi
    if [ "$PLUGINS_FAILED" -gt 0 ]; then
        case "$hook" in
            backup)  warn "Failed plugins:$PLUGINS_FAILED_LIST (run dot-backup again after fixing them)" ;;
            restore) warn "Failed plugins:$PLUGINS_FAILED_LIST (run dot-restore again after fixing them)" ;;
            *)       warn "Failed plugins:$PLUGINS_FAILED_LIST (retry with: dot-plugin run $hook NAME)" ;;
        esac
    fi
    return 0
}

# backup_plugins DEST: run the backup hook of every enabled, installed plugin, storing what they
# return in DEST/.plugin-data/NAME/ (DEST is a snapshot made by snapshot_dotfiles). Plugins that
# stored nothing leave no folder, and the manifest gets a "plugins:" line naming the others.
backup_plugins() {
    local dest="$1" d names=""
    PLUGIN_BACKUP_ROOT="$dest/$PLUGIN_DATA_DIR"
    mkdir -p "$PLUGIN_BACKUP_ROOT"
    run_plugins backup
    for d in "$PLUGIN_BACKUP_ROOT"/*/; do
        [ -d "$d" ] || continue
        rmdir "$d" 2>/dev/null || names="$names $(basename "$d")"
    done
    rmdir "$PLUGIN_BACKUP_ROOT" 2>/dev/null || true
    if [ -n "$names" ] && [ -f "$dest/MANIFEST.txt" ]; then
        printf 'plugins:    %s\n' "${names# }" >>"$dest/MANIFEST.txt"
    fi
    return 0
}
