# Commands to run in interactive sessions can go here
if status is-interactive
    # * Enviroment variables
    set fish_greeting
    set -gx ALTERNATE_EDITOR "" # Allows for daemon to startup if emacsclient can't find one
    set -gx EDITOR "emacsclient -nw"
    set -gx FZF_DEFAULT_OPTS "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    set -gx NIXPKGS_ALLOW_UNFREE 1
    set -gx SHELL /home/serralq/.nix-profile/bin/fish
    # Some programs ask for this implicitly in FHS environment
    # which nix would block so setting it here for global
    set -gx SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
    set -gx CURL_CA_BUNDLE /etc/ssl/certs/ca-bundle.crt
    # TODO Customize fzf as the need arises
    # Bat examples at: https://github.com/sharkdp/bat

    # ** SSH socket issue
    set -gx SSH_AUTH_SOCK /run/user/(id -u)/ssh-agent.sock
    if not test -S "$SSH_AUTH_SOCK"
        ssh-agent -a "$SSH_AUTH_SOCK" -t 8h >/dev/null 2>&1
        ssh-add ~/.ssh/id_ed25519 2>/dev/null
    end
    # ** Environment functions
    functions --erase __direnv_export_eval # To disable direnv for now
    functions --erase __direnv_cd_hook

    # * Regular Aliases
    alias trash="gio trash"
    alias kill="ps aux | fzf | awk '{print \$2}' | xargs kill"
    alias rename="~/.config/hypr/workspace-manager.sh --rename"
    alias mirror="hyprctl keyword monitor HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
    alias extend="hyprctl keyword monitor HDMI-A-1, 1920x1080@60, auto, 1"
    alias mouse-sensitivity="hyprctl -r -- keyword device[nulea-bt5.0-mouse]:sensitivity -0.1"
    funcsave rename >/dev/null # To allow for better argument passing
    # * Replacement alias
    alias less="less -iR"
    alias ls="eza --icons=always --color=always -T --hyperlink -L 1"
    alias rsync="rsync -azvhP"
    alias json-diff="json-diff -S full" # Use with nix-value-json to compare nix outputs
    alias sshs "sshs --exit --template 'mosh \"{{{name}}}\"'" # To connect ssh without lag and to autocomplete username
    # For alias to be ver of original so it autocompletes
    alias xclip-expand="cliphist list | fzf --no-sort | cliphist decode | wl-copy"
    alias nix-search="nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history"
    alias blue="bluetuith -t '25:09:23:B6:08:8C'"
    alias emac="emacsclient -n -c -a \"\" && exit"
    alias claude-resume="claude -r" # To also add reliance on claude-trash script
    alias claude-read="claude-conversation.py" # To read the conversation files
    function opencode-session-all
        sqlite3 ~/.local/share/opencode/opencode-stable.db -column -header \
            "SELECT s.id, s.title, p.worktree, datetime(s.time_updated/1000, 'unixepoch') as updated
             FROM session s JOIN project p ON s.project_id = p.id
             ORDER BY s.time_updated DESC;"
    end
    # ** Pathes
    fish_add_path ~/.scripts
    fish_add_path ~/.config/emacs/bin # Doom emacs path
    # # *** Paths for windows apps
    # alias lime="winapps manual 'C:\Users\serralq\Desktop\Shared\Games\Lime\limelight_lj.exe'"
    # alias tenshi="winapps manual 'C:\Users\serralq\Desktop\Shared\Games\Tenshi\tenshi.exe'"
    # alias textractor="winapps manual 'C:\Users\serralq\Desktop\Shared\Games\Textractor\x86\Textractor.exe'"
    # alias xrdp="xfreerdp /u:'serralq' /p:'TheBest' /v:127.0.0.1 /cert:tofu /dynamic-resolution /sound:sys:pulse"
    # * Global Aliasing, always all caps
    abbr --add SO --position anywhere ' > /dev/null' # Removes std out in logs
    abbr --add NE --position anywhere ' 2> /dev/null' # Removes errors in logs
    abbr --add NULL --position anywhere ' >/dev/null 2>&1' # Removes errors in logs
    abbr --add XC --position anywhere ' | xclip'
    abbr --add APP --position anywhere ' >/dev/null 2>&1 &'
    # * (General) Functions
    function starship_transient_prompt_func --description "Transient left prompt"
        printf " "
        starship module character
    end

    function starship_transient_rprompt_func --description "Plugin functions"
        # Get the current command line
        set -l prev_cmd (commandline)
        set -l prev_cmd_len (string length --visible "$prev_cmd")

        # Calculate window's width
        set -l term_width (tput cols)

        # Calculate available space for dashes
        set -l dash_count (math "max(0, $term_width - $prev_cmd_len - 14)")

        # Echo the dashes
        echo " "
        printf "%s%s%s" (set_color brblack) (string repeat -n $dash_count "―") (set_color normal)
        echo " "
        starship module time
    end

    function yy --description "Move to location after exiting yazi"

        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    function cd --description "Fuzzy cd, then print directory"
        if z $argv
            # Wait is due to prompt having to recalc
            eza --icons=always --color=always -T --hyperlink -L 1 | head -n 12
        else
            # If fail to search
            zi
        end
        yy
    end

    function ccd --description "Redo the fuzzy search"
        # TODO Integrate into yazi instead of quit to do command
        set -l last_cmd (string split " " $history[1])

        if test "$last_cmd[1]" = cd
            zi $last_cmd[2..-1]
        else
            zi
        end
        yy
    end

    function clr --description "Fastfetch only if not in eat"
        clear
        if test "$TERM" != eat-truecolor
            if not set -q TMUX
                printf "       高性能ですから\n"
                fastfetch --config ~/.config/fastfetch/config-spaced.jsonc
            else
                fastfetch
            end
        end

        tput cup (math (tput lines) - 3) 0
    end

    function stow --description 'Restrict GNU Stow to exactly ~/stow or ~/any'
        if contains -- "$PWD" "$HOME/stow" "$HOME/any"
            command stow $argv
        else
            set_color red >&2
            echo "Error: stow can only be run from $HOME/stow or $HOME/any (not subdirectories)" >&2
            set_color normal >&2
            return 1
        end
    end

    function unmount --description 'Unmount all rclone mounts'
        for d in ~/mnt/*/
            fusermount -u "$d" 2>/dev/null
        end
    end

    function rmount --description 'rclone mount an SSH host'
        if test (count $argv) -eq 0
            echo "Usage: rmount <ssh-host > [remote-path]"
            echo "  rmount choshi         → mounts home dir to ~/mnt/choshi"
            echo "  rmount choshi /etc    → mounts /etc to ~/mnt/choshi"
            return 1
        end

        set -l host $argv[1]
        set -l remote_path ""
        if test (count $argv) -ge 2
            set remote_path $argv[2]
        end

        set -l mountdir "$HOME/mnt/$host"
        mkdir -p "$mountdir"

        if mountpoint -q "$mountdir" 2>/dev/null
            echo "$host already mounted at $mountdir"
            return 0
        end

        set -l resolved_host (ssh -G "$host" 2>/dev/null | awk '/^hostname / {print $2}')
        set -l resolved_user (ssh -G "$host" 2>/dev/null | awk '/^user / {print $2}')
        set -l resolved_key (ssh -G "$host" 2>/dev/null | awk '/^identityfile / {print $2; exit}')
        set -l remote ":sftp,host=$resolved_host,user=$resolved_user,key_file=$resolved_key:"

        set -l cache_mode minimal # Options: off, minimal, writes, full

        rclone mount "$remote$remote_path" "$mountdir" --daemon --vfs-cache-mode $cache_mode --skip-links
        and echo "Mounted $host:$remote_path at $mountdir"
        or echo "Failed to mount $host"
    end

    # ** Virtual monitors, so browser doesn't pause video when looking away
    alias headless-create="hyprctl output create headless"
    alias headless-remove="hyprctl output remove"
    # Prefer to use main + v since that's the swap monitor command
    function headless-cast -d "Moves the active window to an auto-detected headless monitor"
        # Take the user's argument, if provided
        set target_mon $argv[1]

        # If no argument is provided, auto-detect the headless monitor
        if test -z "$target_mon"
            set target_mon (hyprctl monitors all | grep "Monitor HEADLESS" | awk '{print $2}' | tail -n 1)

            # Failsafe if it couldn't find one
            if test -z "$target_mon"
                echo "Error: No headless monitor found. Did you run your mkheadless alias?"
                return 1
            end
            echo "Auto-detected headless monitor: $target_mon"
        end

        echo "Focus the window you want to move! Teleporting to $target_mon in 3 seconds..."
        sleep 3
        hyprctl dispatch movewindow mon:$target_mon
        echo "Window moved to $target_mon."
    end

    # ** Nix functions
    function nix-install --description "Nicer nix temporary installs"
        nix shell --impure nixpkgs#$argv
    end

    function nix-unlock --description "Move out of nix-store symlink into writable file"
        for file in $argv
            if test -L "$file"

                # Get the real path in the nix store
                set -l real_path (readlink -f "$file")
                trash "$file"
                cp "$real_path" "$file"
                chmod u+w "$file"
                echo "Unlocked: $file (copied from $real_path)"

            else if test -f "$file"; and not test -w "$file"

                # Handle files that are direct store paths (not symlinks) but read-only
                chmod u+w "$file"
                echo "Made writable: $file"

            else
                echo "Skip: $file is already writable or not a symlink."
            end
        end
    end

    function nix-relock --description "Allow to undo the nix-unlocks"
        set hm (readlink -f ~/.local/state/home-manager/gcroots/current-home)
        $hm/activate
    end
    function nix-hm-conflicts -d "Shows why hm might not be activating"
        set -l lines (sudo journalctl -u home-manager-serralq.service --since "10 min ago" -n 200 --no-pager -o short-iso \
          | grep -E "clobbered | is in the way")
        set -l last_time ""
        for line in $lines
            set -l time (string match -r "^\\S+T(\\S+)" $line)[2]
            set -l file (string match -r "Existing file '([^']+)'" $line)[2]
            if test "$time" != "$last_time"
                printf "\n\e[1m── %s ──\e[0m\n" $time
                set last_time $time
            end
            if string match -q "*clobbered*" $line
                printf "  \e[31m✗ %s\e[0m\n" $file
            else
                printf "  \e[33m⚠ %s\e[0m\n" $file
            end
        end
    end
    function __nh_latest_backup_report -d "reads the latest backup-reports"
        set -l report_dir "$XDG_STATE_HOME/home-manager/backup-reports"
        test -n "$XDG_STATE_HOME"; or set report_dir "$HOME/.local/state/home-manager/backup-reports"

        set -l reports (command ls -1t -- "$report_dir"/*-backup-report 2>/dev/null)
        if test (count $reports) -gt 0
            printf '%s\n' $reports[1]
        end
    end

    function __nh_print_new_backup_report -d "compares the previous and latest backup report"
        set -l previous_report "$argv[1]"
        set -l latest_report (__nh_latest_backup_report)

        if test -n "$latest_report"
            and test "$latest_report" != "$previous_report"
            and test -s "$latest_report"
            set -l count (command wc -l < "$latest_report")

            printf '> Home Manager created %s backup(s):\n' "$count"
            while read -l backup
                printf '> %s\n' "$backup"
            end <"$latest_report"
        else
            printf '> No new Home Manager backups were created.\n'
        end

    end

    function nh-switch -d "replacement for nh os switch, so I can do execute after cmd"
        set -l previous_report (__nh_latest_backup_report)

        command nh os switch $argv
        set -l status_code $status
        test $status_code -ne 0; and return $status_code

        __nh_print_new_backup_report "$previous_report"
    end

    function nh-boot -d "replacement for nh os boot, so I can do execute after cmd"
        set -l previous_report (__nh_latest_backup_report)

        command nh os boot $argv
        set -l status_code $status
        test $status_code -ne 0; and return $status_code

        __nh_print_new_backup_report "$previous_report"
    end
    # *** Fish inside of nix dev env
    if command -q nix-your-shell
        nix-your-shell fish | source
    end

    # ** Hermes functions
    # For preview, and delete hermes chats
    function hermes-review --description "Pick a Hermes session, preview its prompts, optionally delete it"
        set -l db ~/.hermes/state.db

        set -l picked (sqlite3 "$db" "SELECT id, title FROM sessions WHERE archived = 0 ORDER BY started_at DESC;" | fzf --delimiter='|' --with-nth=2)
        if test -z "$picked"
            echo "No session selected."
            return 1
        end

        set -l id (echo $picked | cut -d'|' -f1)
        set -l title (echo $picked | cut -d'|' -f2-)

        echo "=== $title ($id) ==="
        sqlite3 -line "$db" "SELECT content FROM messages WHERE session_id = '$id' AND role = 'user' ORDER BY timestamp ASC;"

        echo ""
        read -P "Delete this session? [y/N] " confirm
        if test "$confirm" = y -o "$confirm" = Y
            hermes sessions delete "$id"
            echo "Deleted $id."
        else
            echo "Kept."
        end
    end

    # * Sourcing plugins
    # Recreate but in async mode
    starship init fish | source
    # Bug: https://github.com/atuinsh/atuin/issues/2940
    # To prevent fish throwing "binding" error
    atuin init fish | source
    zoxide init fish | source
    pay-respects fish --alias fuck | source
    # Optional: bridge completions from other shells (zsh, bash, etc.)
    set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
    carapace _carapace | source
    # Later as rn not up to date, as soon as v2.1 hits
    # devenv hook fish | source
    enable_transience
    fish_vi_key_bindings
    clr
end

# * Start tmux (outside of tmux)
if status is-interactive; and not set -q TMUX
    #     tmux new-session -A -s shared # Shared session, different windows
end

# ** Code runs only inside tmux
if status is-interactive; and set -q TMUX
    # 1. Run fastfetch, force color/processing, and capture lines in one go
    enable_transience
    fish_vi_key_bindings
    clr
end
