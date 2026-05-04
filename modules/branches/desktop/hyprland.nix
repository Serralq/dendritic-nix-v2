{ ... }:
{
  flake-file.inputs = {
    hyprland.url = "github:hyprwm/Hyprland/v0.52.0";
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins/v0.52.0";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";
    hy3.url = "github:outfoxxed/hy3/hl0.52.0";
    hy3.inputs.hyprland.follows = "hyprland";
    hypr-dynamic-cursors.url = "github:VirtCode/hypr-dynamic-cursors/8c1679b87c54e97145cae83e622956d720e88bef";
    hypr-dynamic-cursors.inputs.hyprland.follows = "hyprland";
  };

  den.aspects.hyprland =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          programs.hyprland = {
            enable = true;
            xwayland.enable = true;
            package = pkgs.hyprland;
            portalPackage = pkgs.xdg-desktop-portal-hyprland;
          };
        };

      # * Hyprland
      # Window manager, use of hyprlandPlugins... to get plugins
      # Last updated: March 8, ver 0.52.0 (v53 is broken, v54 doesn't have plugin support yet)
      homeManager =
        { pkgs, inputs, ... }:
        {
          wayland.windowManager.hyprland = {
            enable = true;
            package = pkgs.hyprland;
            systemd.enable = true;
            systemd.variables = [ "--all" ];
            portalPackage = pkgs.xdg-desktop-portal-hyprland;
            plugins = [
              inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
              inputs.hy3.packages.${pkgs.system}.hy3
              inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
              inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
            ];

            # ** General Settings
            settings = {
              # permission = "/usr/(bin|local/bin)/hyprpm, plugin, allow";

              env = [
                "GTK_THEME,Adwaita:dark"
              ];

              monitor = [
                "eDP-1,2880x1800@60,0x0,1.8, bitdepth, 10, cm, hdr"
                "eDP-2,2880x1800@60,0x1000,1.8, bitdepth, 10, cm, hdr" # Bottom monitor
                ",preferred,auto,1" # For auto external monitors
              ];

              general = {
                gaps_in = "4";
                gaps_out = "8";
                border_size = "2";
                "col.inactive_border" = "rgba(595959aa)";
                allow_tearing = "true";
                layout = "hy3";
                resize_on_border = "true";
                extend_border_grab_area = "30";
              };

              group = {
                groupbar = {
                  # TODO add font weight, turn off when not in focus, gradients into hy3
                  # Or into native, borders
                  # Native tabstack vs plugin tab stacks
                  # Both missing: allow for tabs on the bottom
                  # Allow for app name first
                };
              };

              decoration = {
                dim_inactive = "true";
                dim_strength = "0.11";

                shadow = {
                  enabled = "false"; # Battery hogs
                  range = "8";
                  render_power = "2";
                  color = "rgba(1a1a1aee)";
                };

                blur = {
                  enabled = "false";
                  size = "5";
                  passes = "2";
                };
              };

              animations = {
                workspace_wraparound = "true";

                bezier = [
                  "easeOutQuint,0.23,1,0.32,1"
                  "easeInOutCubic,0.65,0.05,0.36,1"
                  "linear,0,0,1,1"
                  "almostLinear,0.5,0.5,0.75,1.0"
                  "quick,0.15,0,0.1,1"
                  "overshoot, 0.05, 0.9, 0.1, 1.1"
                ];

                animation = [
                  "global, 1, 10, default"
                  "windows, 1, 2.75, easeOutQuint, slide"
                  "fade, 1, 1.8, almostLinear"
                  "border, 1, 5.50, easeOutQuint"
                  "workspaces, 1, 2.00, easeOutQuint, slide"

                  # Disabled
                  "windowsMove, 0, 1.49, linear, popin 87%"
                  "layers, 0, 3.81, easeOutQuint"
                ];
              };

              dwindle = {
                pseudotile = "true";
                preserve_split = "true";
              };

              master = {
                new_status = "master";
              };

              #windowrule = [
              #  # "no_focus on, match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pinned false"
              #  "float on, match:title ^(Picture in picture)$"
              #  "pin on, match:title ^(Picture in picture)$"
              #  "size 200 200, match:title ^(Picture in picture)$"
              #  "move 1348 790, match:title ^(Picture in picture)$"
              #];

              windowrulev2 = [
                "float, title:^(Picture in picture)$"
                "pin, title:^(Picture in picture)$"
                "size 200 200, title:^(Picture in picture)$"
                "move 1348 790, title:^(Picture in picture)$"
              ];

              # ** Bindings
              input = {
                kb_options = "caps:escape, ctrl:swap_lalt_lctl";
                # Testing this out
                sensitivity = "1"; # Clamped to 1
                accel_profile = "flat";
                repeat_delay = "180";
                repeat_rate = "50";
                # Allow for click and drag scrolling
                # TODO Remove if not using the trackball
                scroll_method = "on_button_down";
                scroll_button = "275";
                scroll_factor = "0.3";

                touchpad = {
                  natural_scroll = "true";
                  disable_while_typing = "true";
                };

                # To prevent broken screen from creating inputs
                touchdevice = {
                  enabled = "false";
                };
              };

              cursor = {
                hide_on_key_press = "true";
              };

              misc = {
                enable_swallow = true;
                swallow_regex = "(org.wezfurlong.wezterm)";
                vfr = "true";
              };

              "$mainMod" = "SUPER";

              binde = [
                "bind = SUPER, H, exec, wtype -k Left"
                "bind = SUPER, J, exec, wtype -k Down"
                "bind = SUPER, K, exec, wtype -k Up"
                "bind = SUPER, L, exec, wtype -k Right"
              ];

              bindl = [
                "$mainMod, SPACE, exec, wezterm"
                "ALT, SPACE, exec, grimblast copy area" # Screenshots
                # TODO For monitor screen keybindings, don't forget to update debug msg
                # One screen to svae power, two screen to use power
                "$mainMod, B, exec, ~/stow/.config/hypr/battery-saver.sh & "
                "$mainMod SHIFT, B, exec, ~/stow/.config/hypr/second-monitor.sh &"
                # Just adding the commands would fail for some reason to execute the second mpvpaper command
                # Start the bottom monitor and start the wallpaper
                "$mainMod, C, exec, emacsclient -c --eval '(thanos/type)'"
                "$mainMod, V, exec, ~/.config/hypr/workspace-manager.sh --swap-monitors"
                "$mainMod, N, exec, ~/.config/hypr/workspace-manager.sh --debug"
                "$mainMod, W, killactive,"
                "$mainMod, M, exit,"
                # Allow for the initial sleep
                "$mainMod, comma, exec, hyprlock"
                "$mainMod, period, hyprexpo:expo, toggle"
                "$mainMod, slash, exec, ~/.config/hypr/workspace-manager.sh --debug"

                "$mainMod, D, hy3:changegroup, toggletab"
                "$mainMod SHIFT, D, hy3:makegroup, tab, toggle"
                "$mainMod, F, hy3:focustab, r, wrap"
                "$mainMod, S, hy3:focustab, l, wrap"

                # "$mainMod, H, hy3:movefocus, l"
                # "$mainMod, L, hy3:movefocus, r"
                # "$mainMod, K, hy3:movefocus, u"
                # "$mainMod, J, hy3:movefocus, d"

                "$mainMod SHIFT, H, hy3:movewindow, l"
                "$mainMod SHIFT, L, hy3:movewindow, r"
                "$mainMod SHIFT, K, hy3:movewindow, u"
                "$mainMod SHIFT, J, hy3:movewindow, d"

                # TODO Create script for multimonitor support
                # TODO Add rename options to terminal
                # If both on monitor don't change,
                # If either not in monitor
                # Navigation (1-5) within current group
                "$mainMod, 1, exec, ~/.config/hypr/workspace-manager.sh --switch 1"
                "$mainMod, 2, exec, ~/.config/hypr/workspace-manager.sh --switch 2"
                "$mainMod, 3, exec, ~/.config/hypr/workspace-manager.sh --switch 3"
                "$mainMod, 4, exec, ~/.config/hypr/workspace-manager.sh --switch 4"
                "$mainMod, 5, exec, ~/.config/hypr/workspace-manager.sh --switch 5"

                # Group Selection (Mod + Shift + 1-5)
                "$mainMod SHIFT, 1, exec, ~/.config/hypr/workspace-manager.sh --set-group 0"
                "$mainMod SHIFT, 2, exec, ~/.config/hypr/workspace-manager.sh --set-group 1"
                "$mainMod SHIFT, 3, exec, ~/.config/hypr/workspace-manager.sh --set-group 2"
                "$mainMod SHIFT, 4, exec, ~/.config/hypr/workspace-manager.sh --set-group 3"
                "$mainMod SHIFT, 5, exec, ~/.config/hypr/workspace-manager.sh --set-group 4"

                # Move Window to Relative Workspace (Mod + Alt + 1-5)
                "$mainMod ALT, 1, exec, ~/.config/hypr/workspace-manager.sh --move-window 1"
                "$mainMod ALT, 2, exec, ~/.config/hypr/workspace-manager.sh --move-window 2"
                "$mainMod ALT, 3, exec, ~/.config/hypr/workspace-manager.sh --move-window 3"
                "$mainMod ALT, 4, exec, ~/.config/hypr/workspace-manager.sh --move-window 4"
                "$mainMod ALT, 5, exec, ~/.config/hypr/workspace.sh --move-window 5"

                # Move Active Window to same slot in a different Group (Mod + Alt + Shift + 1-5)
                "$mainMod ALT SHIFT, 1, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 0"
                "$mainMod ALT SHIFT, 2, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 1"
                "$mainMod ALT SHIFT, 3, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 2"
                "$mainMod ALT SHIFT, 4, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 3"
                "$mainMod ALT SHIFT, 5, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 4"

                "$mainMod, mouse_down, workspace, e+1"
                "$mainMod, mouse_up, workspace, e-1"

                # Probably should make a flag since this right only speaker is a asus laptop only issue
                # ", F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\" & "
                # ", F3, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ & wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\" & "
                ", F2, exec, if case \"$(pactl get-default-sink)\" in *Speaker*) true;; *) false;; esac; then L=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub(/%/,\"\"); print $5}'); R=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub(/%/,\"\"); print $12}'); R=$((R - 5)); [ \"$R\" -lt 0 ] && R=0; pactl set-sink-volume @DEFAULT_SINK@ \"\${L}%\" \"\${R}%\"; dunstify -u low -r 9910 \"Volume: R \${R}%\"; else wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\"; fi"
                ", F3, exec, if case \"$(pactl get-default-sink)\" in *Speaker*) true;; *) false;; esac; then L=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub(/%/,\"\"); print $5}'); R=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub(/%/,\"\"); print $12}'); R=$((R + 5)); [ \"$R\" -gt 100 ] && R=100; wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; pactl set-sink-volume @DEFAULT_SINK@ \"\${L}%\" \"\${R}%\"; dunstify -u low -r 9910 \"Volume: R \${R}%\"; else wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\"; fi"
                ", F5, exec, brightnessctl s 10%- & brightnessctl -d intel_backlight s 10%-"
                ", F6, exec, brightnessctl s 10%+ & brightnessctl -d intel_backlight s 10%+"

                ", XF86AudioNext, exec, playerctl next"
                ", XF86AudioPause, exec, playerctl play-pause"
                ", XF86AudioPlay, exec, playerctl play-pause"
                ", XF86AudioPrev, exec, playerctl previous"

                ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"
                ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
                ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
                ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"

                # TODO Doesn't work since left is sent along with the ctrl
                # "CTRL, H, exec, wtype -k Left"
                # "CTRL, J, exec, wtype -k Down"
                # "CTRL, K, exec, wtype -k Up"
                # "CTRL, L, exec, wtype -k Right"
              ];

              bindm = [
                "$mainMod, mouse:272, movewindow"
                "$mainMod, mouse:273, resizewindow"
              ];

              # ** Plugins
              plugin = {
                dynamic-cursors = {
                  enabled = "true";
                  mode = "tilt";

                  tilt = {
                    function = "quadratic";
                    window = "100";
                    limit = "1500";
                  };

                  shake = {
                    enabled = "false";
                  };
                };

                hyprtrails = {
                  color = "rgba(88C0D0FF)";
                };

                hyprexpo = {
                  columns = "5";
                  gap_size = "0";
                  bg_col = "rgb(000000)";
                  workspace_method = "center current";
                };

                hy3 = {
                  tab_first_window = "true";
                  tabs = {
                    text_font = "Hermit";
                    text_height = "10";
                    border_width = "4";
                    "col.inactive" = "rgba(595959DD)";
                    "col.inactive.border" = "rgba(2E3440FF)";
                    "col.active" = "rgba(5E81ACFF)";
                    "col.active.border" = "rgba(2E3440FF)";
                  };
                };
              };
            };
          };
        };
    };
}
