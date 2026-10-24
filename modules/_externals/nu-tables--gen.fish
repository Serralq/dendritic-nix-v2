# This file is sourced, not autoloaded, so scripts never inherit the wrappers.
status is-interactive; or return
command -q nu; or return

set -g __nu_tables_script (path dirname (status filename))/nu-tables.nu
set -l cache_root "$HOME/.cache"
set -q XDG_CACHE_HOME; and set cache_root "$XDG_CACHE_HOME"
set -g __nu_tables_cache "$cache_root/nu-tables/commands.tsv"
set -q __nu_tables_wrapped; or set -g __nu_tables_wrapped

function __nu_tables_load
    for name in $__nu_tables_wrapped
        test "$name" = ls; and continue
        functions --erase -- $name
    end
    set -g __nu_tables_wrapped
    while read -l line
        set -l fields (string split \t -- "$line")
        test (count $fields) -eq 3; or continue
        set -l name $fields[1]
        test "$name" = ls; and continue
        set -l mode $fields[2]
        set -l parser $fields[3]
        command -q -- $name; or continue
        builtin -q -- $name; and continue
        functions -q -- $name; and continue
        function $name --inherit-variable name --inherit-variable mode --inherit-variable parser --description 'Automatically render command output through Nushell'
            set -l executable (command -s -- $name)
            # Completion helpers and pipelines need the original machine-readable output.
            if status is-command-substitution; or not isatty stdout
                command "$executable" $argv
                return $status
            end
            command nu --no-config-file "$__nu_tables_script" run -- $mode $name "$executable" $parser $argv
        end
        set -ga __nu_tables_wrapped $name
    end <"$__nu_tables_cache"
end

function nu-tables-refresh --description 'Rebuild table wrappers; --json also enables verified JSON adapters'
    if test (count $argv) -gt 1; or test (count $argv) -eq 1; and test "$argv[1]" != --json
        printf 'Usage: nu-tables-refresh [--json]\n' >&2
        return 2
    end
    command mkdir -p -- (path dirname "$__nu_tables_cache"); or return
    set -l scan
    contains -- --json $argv; and set scan --scan-json
    command nu --no-config-file "$__nu_tables_script" discover $scan >"$__nu_tables_cache.tmp"
    set -l result $status
    if test $result -ne 0
        command rm -f -- "$__nu_tables_cache.tmp"
        return $result
    end
    command mv -- "$__nu_tables_cache.tmp" "$__nu_tables_cache"; or return
    __nu_tables_load
end

if not test -f "$__nu_tables_cache"
    # Initial discovery only reads metadata; JSON adapters are explicitly requested.
    nu-tables-refresh
else
    __nu_tables_load
end
