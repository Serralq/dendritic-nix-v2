function sops-export --description 'Export a user SOPS runtime secret into this Fish session'
    if test (count $argv) -eq 1; and contains -- "$argv[1]" -h --help
        printf '%s\n' \
            'Usage: sops-export VARIABLE [FOLDER_OR_FILE]' \
            'Defaults to the user-owned secret path declared by sops-nix.' \
            'VARIABLE is the uppercase secret name with hyphens replaced by underscores.' \
            'An optional file or folder must contain already-decrypted secrets.' \
            'Example: sops-export HCLOUD_TOKEN'
        return 0
    end

    if test (count $argv) -lt 1; or test (count $argv) -gt 2
        printf '%s\n' 'Usage: sops-export VARIABLE [FOLDER_OR_FILE]' >&2
        return 2
    end

    if not string match --quiet --regex '^[A-Za-z_][A-Za-z0-9_]*$' -- "$argv[1]"
        printf '%s\n' 'sops-export: invalid environment variable name.' >&2
        return 2
    end

    if test "$argv[1]" = SOPS_EXPORTED_VARIABLES
        printf '%s\n' 'sops-export: SOPS_EXPORTED_VARIABLES is reserved for prompt tracking.' >&2
        return 2
    end

    set -l secret_file
    switch "$argv[1]"
        @secret-cases@
        case '*'
            printf 'sops-export: no user SOPS secret declared for %s\n' "$argv[1]" >&2
            return 1
    end

    if test (count $argv) -eq 2
        if test -d "$argv[2]"
            set secret_file "$argv[2]/"(path basename "$secret_file")
        else
            set secret_file "$argv[2]"
        end
    end
    if not test -f "$secret_file"; or not test -r "$secret_file"
        printf 'sops-export: secret file missing or unreadable: %s\n' "$secret_file" >&2
        return 1
    end

    # Keep empty strings and multiline values intact, including trailing newlines.
    set -l secret (command @jq@ --raw-input --slurp --join-output '
        if index("\u0000") == null then . else error("secret contains NUL bytes") end
    ' -- "$secret_file" | string collect --allow-empty --no-trim-newlines)
    set -l result $pipestatus
    # string collect can return 1 for an empty file; jq reports read and validation errors.
    if test "$result[1]" -ne 0
        return 1
    end

    set --global --export "$argv[1]" "$secret"
    or return 1

    set -l exported_names (string split --no-empty ', ' -- "$SOPS_EXPORTED_VARIABLES")
    if not contains -- "$argv[1]" $exported_names
        set --global --export SOPS_EXPORTED_VARIABLES (string join ', ' -- $exported_names "$argv[1]")
    end
    return 0
end
