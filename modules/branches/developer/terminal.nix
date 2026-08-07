{ ... }:
{
  den.aspects.terminal =
    { ... }:
    {
      nixos =
        {
          pkgs,
          config,
          lib,
          ...
        }:
        {
          assertions = [
            {
              assertion = builtins.elem pkgs.hermit config.fonts.packages;
              message = "den.aspects.terminal requires Hermit font (den.aspects.font)";
            }
          ];
        };

      homeManager =
        { pkgs, config, ... }:
        {
          xdg.configFile."wezterm/wezterm.lua".text = ''
                        -- Pull in the wezterm API
                        local wezterm = require("wezterm")

                        local tui_programs = {
                          "${pkgs.opencode}/bin/opencode",
                          "${pkgs.emacs-pgtk}/bin/emacs",
                        }

                        wezterm.on('update-status', function(window, pane)
                          local overrides = window:get_config_overrides() or {}
                          local process = pane:get_foreground_process_name() or ""

                          local is_tui = false
                          for _, path in ipairs(tui_programs) do
                            local name = path:match("[^/]+$")
                            if process:find(name, 1, true) then
                              is_tui = true
                              break
                            end
                          end

                          if is_tui then
                            overrides.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
                          else
                            overrides.window_padding = nil
                          end
                          window:set_config_overrides(overrides)
                        end)

                        return {

                          -- Default
                          default_prog = { "${pkgs.fish}/bin/fish" },
                          -- Colors
                          color_scheme = "nord",
                          colors = { background = "#202329" },

                          -- Fonts
                          font = wezterm.font("Hermit"),
                          font_size = 10,

                          -- Background
                          window_decorations = "NONE",
                          window_background_opacity = 0.97,

                          -- Etc.
                          hide_tab_bar_if_only_one_tab = true,

                          inactive_pane_hsb = {
                            saturation = 0.5,
                            brightness = 0.3,
                          },
                          -- Copy mode with ctrl + shift + x

                          -- Shift enter to work in claude code
                          enable_kitty_keyboard = true,

            	            initial_cols = 180,
            	            initial_rows = 50,
                        }
          '';

          # For tmux
          xdg.configFile."tmux/tmux.conf".text = ''
            set -g default-shell "${pkgs.fish}/bin/fish"
            set -g default-command "${pkgs.fish}/bin/fish"

            set -g status-position top
            set -g status-style "bg=default,fg=#e5e9f0"
            set -g status-left " #S "
            set -g status-right ""
            set -g window-status-format " #I #W "
            set -g window-status-current-format " #[fg=#a3be8c,bold]#I #W#[default] "
            set -g status-justify left
            set -g allow-passthrough on

            # Hide pane borders while retaining tmux pane separation.
            set -g pane-border-style "fg=default,bg=default"
            set -g pane-active-border-style "fg=default,bg=default"

            # Navigate windows without the tmux prefix.
            bind-key -n C-s previous-window
            bind-key -n C-f next-window
            bind-key -n C-n new-window
            bind-key -n C-x kill-window

            # Ctrl+p opens the native tmux command menu.
            bind-key -n C-p display-menu -T " tmux " \
            "New window" n "new-window" \
            "Split horizontally" h "split-window -v" \
            "Split vertically" v "split-window -h" \
            "Next window" l "next-window" \
            "Previous window" k "previous-window" \
            "Rename window" r "command-prompt -p 'Window name:' 'rename-window \"%%\"'" \
            "Kill pane" x "kill-pane" \
            "Kill window" X "kill-window" \
            "Zoom pane" z "resize-pane -Z" \
            "Choose session, window, or pane" t "choose-tree -Zw" \
            "Reload tmux configuration" R "source-file ~/.config/tmux/tmux.conf" \
            "Detach session" d "detach-client"
          '';

          home.file.".local/bin/tmux-palette" = {
            executable = true;
            text = ''
              #!/bin/sh
              set -eu

              choice=$(cat <<'EOF' | ${pkgs.fzf}/bin/fzf --layout=reverse --border --prompt='tmux> '
              New window
              Split pane horizontally
              Split pane vertically
              Next window
              Previous window
              Rename window
              Kill pane
              Kill window
              Zoom pane
              Choose session, window, or pane
              Reload tmux configuration
              Detach session
              EOF
              ) || exit 0

              case "$choice" in
                "New window") tmux new-window ;;
                "Split pane horizontally") tmux split-window -v ;;
                "Split pane vertically") tmux split-window -h ;;
                "Next window") tmux next-window ;;
                "Previous window") tmux previous-window ;;
                "Rename window") tmux command-prompt -p "Window name:" "rename-window '%%'" ;;
                "Kill pane") tmux kill-pane ;;
                "Kill window") tmux kill-window ;;
                "Zoom pane") tmux resize-pane -Z ;;
                "Choose session, window, or pane") tmux choose-tree -Zw ;;
                "Reload tmux configuration") tmux source-file "$HOME/.config/tmux/tmux.conf" ;;
                "Detach session") tmux detach-client ;;
              esac
            '';
          };

          home.packages = with pkgs; [
            # * Terminal emulators
            wezterm # Terminal
            kitty # For testing + wayland

            # * Shell / Prompt
            mosh # Allow for typing before response back in ssh
            neovim # Basic editor
            starship # Terminal prompt look
            fastfetch # Terminal splash screen
            yazi # File manager
            zoxide # Quick jump
            atuin # Terminal History
            pay-respects # Fixing previous terminal command
            fishPlugins.fifc # Fish auto completion fzf
            nushell # When I need structured contents
            carapace # Better terminal autocomplete
            tmux # For multiplexing, also works on remote machines

            # * CLI utilities
            bat # Better cat
            ripgrep # Greps but faster, written in Rust
            fzf # Fuzzy finder
            fd # A better find
            eza # Better ls
            mediainfo # Allow for more media preview in yazi
            ueberzugpp # For yazi image preview
            su-exec # Allow for switching user and then execute
            jc # JSON parser for stdout
            jq # JSON parser for stdout
          ];
        };
    };
}
