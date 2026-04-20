{
  pkgs,
  den,
  lib,
  ...
}:

{
  flake-file.inputs = {
    hyprland.url = "github:hyprwm/Hyprland/v0.52.0";
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins/v0.52.0";
    hy3.url = "github:outfoxxed/hy3/hl0.52.0";
    hypr-dynamic-cursors.url = "github:VirtCode/hypr-dynamic-cursors/8c1679b87c54e97145cae83e622956d720e88bef";
  };

  den.aspects.desktop-environment = { config, ... }: {
    includes = [
      den.aspects.font
    ];

    nixos = { pkgs, ... }: {
      # ** Window Manager
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = pkgs.hyprland;
        portalPackage = pkgs.xdg-desktop-portal-hyprland;
      };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # Enable the X11 windowing system and GNOME as backup
      services.xserver.enable = true;
      services.desktopManager.gnome.enable = true;

      services.displayManager.ly.enable = true;

      # ** Xdg portals
      xdg.portal = {
        enable = true;

        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.xdg-desktop-portal-termfilechooser
        ];

        config = {
          hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
          };
          common = {
            default = [ "gtk" ];
          };
        };
      };
    };

    homeManager =
      {
        pkgs,
        inputs,
        lib,
        ...
      }:
      {
        # ** Hyprland / DE / Keyboard-shortcuts
        home.packages = with pkgs; [
          cliphist # Clipboard manager
          wl-clipboard
          ydotool
          grimblast # Better screenshots
          brightnessctl # For brightness cmd
          waybar # TODO create a currently listening
          mpvpaper
          socat # Control forked mpvpaper
          playerctl # Allow to check what's currently playing
          hyprcursor # TODO Util to convert Xcursor to hyprcursor
          xcur2png # Help extract xcursor
          # TODO LWP Settup in the future
          pmutils # Check battery -> Change border colors
          nwg-look # Affects the mouse cursor in a different way
          kitty # For hyprland fallback
          waypaper # Basic wallpaper GUI
          wtype # Allow to send keymaps
          # TODO Learn to package a app launcher that has premade plugins (vicinae)
          # TODO Auto pause background music when detect another audio is playing
          # Waybar already has rust plugin that can detect what's currently playing
          # TODO https://www.wfdownloader.xyz/download to mass download twitter posts
          hyprpicker # Get colors from screen
          wev # Figure out what output from input devices
          hypridle # For locking the computer
        ];

        # ** Notifications: Dunst
        # Notification daemon, search "notify-send" to find
        # Only if requires immediate action
        services.dunst.enable = true;
        services.dunst.settings = {
          global = {
            offset = "(8, 8)";
            origin = "top-right";
            frame_width = "2";
            font = "Hermit";
            follow = "mouse";
            background = "#2e3440";
            width = "(80,300)";
          };
          urgency_normal = {
            frame_color = "#a3be8c";
            foreground = "#a3be8c";
            # Just long enough for me to notice
            timeout = "2";
          };
          urgency_low = {
            foreground = "#5e81ac";
            frame_color = "#5e81ac";
            timeout = "2";
          };
          urgency_critical = {
            foreground = "#bf616a";
            frame_color = "#bf616a";
            timeout = "30";
          };
        };

        # ** Hyprlock
        programs.hyprlock.enable = true;
        programs.hyprlock.settings = {
          general = {
            hide_cursor = true;
            ignore_empty_input = true;
            fail_timeout = 1000; # Just long enough to feel this
          };
          background = {
            # Type of background
            path = "screenshot";
            monitor = "";
            # Background settings
            blur_passes = 1;
            blur_size = 6;
            brightness = 0.7;
            noise = 0;
          };
          input-field = {
            # Size
            size = "500, 150"; # Height controls font size, 440 keeps it balanced
            outline_thickness = 6;
            # Position
            monitor = "";
            halign = "center";
            valign = "center";
            # Shape
            rounding = 0;
            # Behavior
            hide_input = true;
            fade_on_empty = false;
            # Text
            font_family = "Hermit";
            placeholder_text = "<i>最高性ですから</i>";
            fail_text = "ダメ";
            # Colors
            font_color = "rgba(216, 222, 233, 1)";
            inner_color = "rgba(0,0,0,0.0)";
            outer_color = "rgba(46, 52, 64, 1) rgba(76, 86, 106, 1) 90deg";
            fail_color = "rgba(191, 97, 106, 1) rgba(208, 135, 112, 1) 90deg";
            check_color = "rgba(94, 129, 172, 1) rgba(136, 192, 208, 1) 90deg";
          };
          animations = {
            animation = [
              # Disabled animations
              "fadeOut, 0, 1" # Disable else delays the notification popup
              "inputFieldWidth, 0, 10"
              "inputFieldDots, 0, 10"
              "inputFieldFade, 0, 10"
              # Enabled animation
              "inputFieldColors, 1, 50"
              # (transitions for the entire length that blue / red appears)
              # (multiple of the actual animation so it doesn't complete before next transition)
              "fadeIn, 1, 10" # (within fastest time to type password)
            ];
          };
        };

        # ** HyprIdle (handles locking + dim brightness on idle)
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              on_unlock_cmd = lib.concatStringsSep " " [
                "/home/serralq/.scripts/border-color.sh --all &"
                "pactl set-sink-volume @DEFAULT_SINK@ 0% &"
              ];
            };
            listener = [
              {
                timeout = 600;
                on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -d intel_backlight s 10% ; ${pkgs.brightnessctl}/bin/brightnessctl s 10%";
                on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -d intel_backlight s 100% ; ${pkgs.brightnessctl}/bin/brightnessctl s 100%";
              }
            ];
          };
        };

        # * Hyprland
        # Window manager, use of hyprlandPlugins... to get plugins
        # Last updated: March 8, ver 0.52.0 (v53 is broken, v54 doesn't have plugin support yet)
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
            permission = "/usr/(bin|local/bin)/hyprpm, plugin, allow";

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
              "$mainMod ALT, 5, exec, ~/.config/hypr/workspace-manager.sh --move-window 5"

              # Move Active Window to same slot in a different Group (Mod + Alt + Shift + 1-5)
              "$mainMod ALT SHIFT, 1, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 0"
              "$mainMod ALT SHIFT, 2, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 1"
              "$mainMod ALT SHIFT, 3, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 2"
              "$mainMod ALT SHIFT, 4, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 3"
              "$mainMod ALT SHIFT, 5, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 4"

              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up, workspace, e-1"

              ", F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\" & "
              ", F3, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ & wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\" & "
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
