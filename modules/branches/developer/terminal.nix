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
