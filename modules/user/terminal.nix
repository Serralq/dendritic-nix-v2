{ den, ... }:
{
  den.aspects.terminal = { user, ... }: {
    includes = [ den.aspects.starship ];

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        assertions = [
          {
            assertion = lib.elem pkgs.hermit config.fonts.packages;
            message = "terminal requires Hermit; add pkgs.hermit to fonts.packages.";
          }
        ];

        programs.fish.enable = true;
        users.defaultUserShell = pkgs.fish;
      };

    homeManager =
      { pkgs, ... }:
      {
        xdg.configFile."kitty/kitty.conf".source = user.externals + "/kitty.conf";
        xdg.configFile."fish/config.fish".source = user.externals + "/config.fish";
        xdg.configFile."fish/nu-tables.fish".source = user.externals + "/nu-tables--gen.fish";
        xdg.configFile."fish/nu-tables.nu".source = user.externals + "/nu-tables--gen.nu";
        xdg.configFile."fastfetch/config-spaced.jsonc".source = user.externals + "/config-spaced.jsonc";
        xdg.configFile."fastfetch/config.jsonc".source = user.externals + "/config.jsonc";
        xdg.configFile."fastfetch/atri.png".source = user.externals + "/atri.png";
        xdg.configFile."wezterm/wezterm.lua".text = ''
          -- Pull in the wezterm API
          local wezterm = require("wezterm")
          local act = wezterm.action

          wezterm.on('update-status', function(window)
            local overrides = window:get_config_overrides() or {}

           overrides.window_padding = { top = 0, left = 0, right = 0, bottom = 0 }
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
            window_background_opacity = 0.92,

            -- Etc.
            hide_tab_bar_if_only_one_tab = true,

            inactive_pane_hsb = {
              saturation = 0.5,
              brightness = 0.3,
            },
            -- Disabling shortcuts for other programs
            keys = {
              { key = "z", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
              { key = "x", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
              { key = "0", mods = "CTRL", action = act.DisableDefaultAssignment },
              { key = "0", mods = "CTRL|SHIFT", action = act.ResetFontSize },
            },

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
          # Regular mouse scrolling
          set -g mouse on
          # Aligning with my keyboard
          set -g base-index 1
          # Maximize keyboard compadiblity
          set -s extended-keys always
          set -s extended-keys-format csi-u
          # Disable keybinds, use just my customs
          set -g prefix None
          unbind -T prefix C-b

          # Vi style copy mode
          set -g mode-keys vi
          bind-key -n C-Z copy-mode
          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
          bind-key -T copy-mode-vi '{' send-keys -X page-up
          bind-key -T copy-mode-vi '}' send-keys -X page-down

          set -g status-position top
          set -g status-style "bg=default,fg=#e5e9f0"
          set -g status-left " #S "
          set -g status-right ""
          # Internal window 10 is displayed as 0 to follow keyboard number order.
          set -g window-status-format " #{?#{==:#{window_index},10},0,#{window_index}} #W "
          set -g window-status-current-format " #[fg=#a3be8c,bold]#{?#{==:#{window_index},10},0,#{window_index}} #W#[default] "
          set -g status-justify left
          set -g allow-passthrough on

          # Hide pane borders while retaining tmux pane separation.
          set -g pane-border-style "fg=default,bg=default"
          set -g pane-active-border-style "fg=default,bg=default"

          # Navigate windows without the tmux prefix.
          bind-key -n C-s previous-window
          bind-key -n C-f next-window
          bind-key -n C-n new-window
          bind-key -n C-X kill-window

          # To select via numbers
          bind-key -n C-0 select-window -t :10
          bind-key -n C-1 select-window -t :1
          bind-key -n C-2 select-window -t :2
          bind-key -n C-3 select-window -t :3
          bind-key -n C-4 select-window -t :4
          bind-key -n C-5 select-window -t :5
          bind-key -n C-6 select-window -t :6
          bind-key -n C-7 select-window -t :7
          bind-key -n C-8 select-window -t :8
          bind-key -n C-9 select-window -t :9

          # Ctrl+p opens the native tmux command menu.
          bind-key -n C-p display-menu -T " tmux " \
          "New window" n "new-window" \
          "Split horizontally" h "split-window -v" \
          "Split vertically" v "split-window -h" \
          "Next window" s "next-window" \
          "Previous window" f "previous-window" \
          "Rename window" r "command-prompt -p 'Window name:' 'rename-window \"%%\"'" \
          "Kill pane" x "kill-pane" \
          "Kill window" X "kill-window" \
          "Zoom pane" z "resize-pane -Z" \
          "Choose session, window, or pane" t "choose-tree -Zw" \
          "Reload tmux configuration" R "source-file ~/.config/tmux/tmux.conf" \
          "Detach session" d "detach-client"
        '';

        home.packages = with pkgs; [
          # * Terminal emulators
          wezterm # Terminal
          kitty # For testing + wayland

          # * Shell / Prompt
          neovim # Basic editor
          starship # Terminal prompt look
          fastfetch # Terminal splash screen
          yazi # File manager
          zoxide # Quick jump
          atuin # Terminal History
          pay-respects # Fixing previous terminal command
          fishPlugins.fifc # Fish auto completion fzf
          television # Prebuilt things to fuzzy search
          nushell # When I need structured contents
          carapace # Better terminal autocomplete
          tmux # For multiplexing, also works on remote machines
          tmuxinator # Project-local tmux session layouts
          fish # My default shell
          tldr # Quick manuals

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
