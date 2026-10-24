def external-adapters [] {
    [
        {name: df, mode: jc, parser: '--df', options: '^(-[ahHklPT]+|--all|--human-readable|--si|--local|--portability|--print-type|--total|--sync|--no-sync)$', values: [], operands: true,
            container: null, header: '^Filesystem\s+.*Mounted on\s*$', shape: list,
            schema: {filesystem: string, size: number, used: number, available: number, use_percent: number, mounted_on: string}}
        {name: free, mode: jc, parser: '--free', options: '^(-[bkmghwlt]+|--bytes|--kibi|--mebi|--gibi|--human|--wide|--lohi|--total)$', values: [], operands: false,
            container: null, header: '^\s*total\s+used\s+free\s+', shape: list,
            schema: {type: string, total: number, used: number, free: number}}
        {name: lsmod, mode: jc, parser: '--lsmod', options: '^$', values: [], operands: false,
            container: null, header: '^Module\s+Size\s+Used by\s*$', shape: list,
            schema: {module: string, size: number, used: number}}
        {name: uptime, mode: jc, parser: '--uptime', options: '^$', values: [], operands: false,
            container: null, header: '^.*\bup\b.*load averages?:', shape: record,
            schema: {uptime_total_seconds: number, users: number, load_1m: number, load_5m: number, load_15m: number}}
        {name: lsblk, mode: json, parser: '-', options: '^(-[abdflp]+|--all|--bytes|--nodeps|--fs|--list|--paths|--json)$', values: [-o --output], operands: true,
            container: blockdevices, header: '', shape: list, schema: {}}
        {name: findmnt, mode: json, parser: '-', options: '^(-[alr]+|--all|--list|--real|--pseudo|--json)$', values: [-o --output -t --types -S --source -T --target], operands: true,
            container: filesystems, header: '', shape: list, schema: {}}
        {name: lscpu, mode: json, parser: '-', options: '^(--json|--bytes)$', values: [], operands: false,
            container: lscpu, header: '', shape: list, schema: {field: string, data: string}}
    ]
}

def supported-invocation [adapter: record, args: list<string>] {
    mut operand_only = false
    mut needs_value = false
    for arg in $args {
        if $needs_value {
            if $arg starts-with '-' { return false }
            $needs_value = false
        } else if $operand_only {
            if not $adapter.operands { return false }
        } else if $arg == '--' {
            $operand_only = true
        } else if $arg in $adapter.values {
            $needs_value = true
        } else if $arg starts-with '--' and '=' in $arg {
            let pair = ($arg | split row --number 2 '=')
            if $pair.0 not-in $adapter.values or ($pair.1 | is-empty) { return false }
        } else if $arg starts-with '-' {
            if $arg !~ $adapter.options { return false }
        } else if not $adapter.operands {
            return false
        }
    }
    not $needs_value
}

def matches-schema [data: any, schema: record] {
    if ($data | describe) !~ '^record' { return false }
    for field in ($schema | transpose name kind) {
        let kind = (try { $data | get $field.name | describe } catch { return false })
        if $field.kind == number {
            if $kind not-in [int float] { return false }
        } else if $kind != $field.kind { return false }
    }
    true
}

def valid-output [data: any, adapter: record] {
    try {
        let rows = if $adapter.container != null { $data | get $adapter.container } else { $data }
        if $adapter.shape == record { return (matches-schema $rows $adapter.schema) }
        if ($rows | describe) !~ '^(list|table)' { return false }
        if $adapter.mode == jc and ($rows | is-empty) { return false }
        $rows | all {|row| matches-schema $row $adapter.schema }
    } catch { false }
}

def 'main discover' [--scan-json] {
    let executables = ($env.PATH | each {|dir|
        try {
            glob ($dir | path join '*') | where {|file|
                let target = ($file | path expand)
                ($target | path type) == file and (try { (ls -l $target | first | get mode) =~ 'x' } catch { false })
            }
        } catch { [] }
    } | flatten | each {|file| {name: ($file | path basename), path: $file}} | uniq-by name
      | where name =~ '^[a-zA-Z0-9_][a-zA-Z0-9_.+-]*$')
    let native = (scope commands | where type == built-in and is_sub == false | get name)
    let parsers = (try { ^jc --about | from json | get parsers } catch { [] })
    mut rows = []
    for executable in $executables {
        let name = $executable.name
        # Shell/session control and the dispatcher itself must stay outside child Nu.
        if $name in [nu jc fish exit exec cd source export env nu-tables-refresh ping ping6 watch top tail vmstat curl bluetoothctl] { continue }
        if $name in $native {
            $rows = ($rows | append {name: $name, mode: native, parser: '-'})
            continue
        }
        let adapters = (external-adapters | where name == $name)
        if not ($adapters | is-empty) {
            let adapter = ($adapters | first)
            if ($adapter.mode == json and $scan_json) or ($adapter.mode == jc and ($parsers | any {|parser| $parser.argument == $adapter.parser })) {
                $rows = ($rows | append {name: $name, mode: $adapter.mode, parser: $adapter.parser})
            }
        }
    }
    $rows | sort-by name | to tsv --noheaders
}

def 'main run' [mode: string, name: string, executable: string, parser: string, ...args: string] {
    if $mode == native {
        # Nu needs flag tokens in source; all values are encoded as Nu literals.
        let shapes = (scope commands | where name == $name | first | get signatures | values | flatten | get syntax_shape)
        let tokens = ($args | each {|arg|
            if $arg =~ '^--?[a-zA-Z][a-zA-Z0-9-]*$' or $arg == '--' {
                $arg
            } else if $arg =~ '^--[a-zA-Z][a-zA-Z0-9-]*=' {
                let pair = ($arg | split row --number 2 '=')
                $pair.0 + '=' + ($pair.1 | to nuon)
            } else if ($arg =~ '^-?[0-9]+(?:\.[0-9]+)?$') and ($shapes | any {|shape| $shape in [int float number] }) {
                $arg
            } else if ($arg =~ '^[0-9]+(?:\.[0-9]+)?(?:ns|us|ms|sec|min|hr|day|wk)$') and ('duration' in $shapes) {
                $arg
            } else {
                $arg | to nuon
            }
        })
        ^nu --no-config-file --commands ($name + ' ' + ($tokens | str join ' '))
        exit $env.LAST_EXIT_CODE
    }

    # Validate at execution time as well: existing caches may contain unverified entries.
    let adapters = (external-adapters | where name == $name and mode == $mode and parser == $parser)
    if ($adapters | is-empty) {
        ^$executable ...$args
        exit $env.LAST_EXIT_CODE
    }
    let adapter = ($adapters | first)
    if not (supported-invocation $adapter $args) {
        ^$executable ...$args
        exit $env.LAST_EXIT_CODE
    }
    let command_args = if $mode == json and not ($args | take while {|arg| $arg != '--' } | any {|arg| $arg == '--json' }) {
        # Insert before -- so it is not treated as an operand.
        if '--' in $args {
            let boundary = ($args | enumerate | where item == '--' | first | get index)
            ($args | take $boundary) | append '--json' | append ($args | skip $boundary)
        } else { $args | append '--json' }
    } else { $args }
    let result = (do { ^$executable ...$command_args } | complete)
    print --stderr --no-newline $result.stderr
    if $result.exit_code != 0 {
        print --no-newline $result.stdout
        exit $result.exit_code
    }
    if $mode == jc and (($result.stdout | lines | first 1 | str join '') !~ $adapter.header) {
        print --no-newline $result.stdout
        exit $result.exit_code
    }
    let parsed = if $mode == jc {
        let converted = ($result.stdout | ^jc $parser | complete)
        if $converted.exit_code == 0 and ($converted.stderr | is-empty) {
            try {
                let data = ($converted.stdout | from json)
                {ok: (valid-output $data $adapter), data: $data}
            } catch { {ok: false} }
        } else { {ok: false} }
    } else {
        try {
            let data = ($result.stdout | from json)
            {ok: (valid-output $data $adapter), data: $data}
        } catch { {ok: false} }
    }
    if $parsed.ok {
        print ($parsed.data | table)
    } else {
        print --no-newline $result.stdout
    }
    exit $result.exit_code
}

def main [] { help main }
