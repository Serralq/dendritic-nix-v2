{ ... }:
{
  flake-file.inputs = {
    hyprland.url = "github:hyprwm/Hyprland/v0.56.1";
    hy3.url = "github:outfoxxed/hy3/hl0.56.0.1";
    hy3.inputs.hyprland.follows = "hyprland";
    hypr-dynamic-cursors.url = "github:VirtCode/hypr-dynamic-cursors/f5ba36c7622098b53bf62ddb8ddf03b914abbdf8";
    hypr-dynamic-cursors.inputs.hyprland.follows = "hyprland";
    hyprexpo.url = "github:sandwichfarm/hyprexpo/v0.56.1";
    hyprexpo.inputs.hyprland.follows = "hyprland";
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
      # Last updated: July 29 2026, ver 0.56.1 (hyprexpo moved to sandwichfarm fork, hyprtrails dropped upstream)
      homeManager =
        {
          pkgs,
          inputs,
          lib,
          ...
        }:
        let
          lua = lib.generators.mkLuaInline;

          dsp = {
            exec = command: lua "hl.dsp.exec_cmd(${builtins.toJSON command})";
            close = lua "hl.dsp.window.close()";
            exit = lua "hl.dsp.exit()";
            drag = lua "hl.dsp.window.drag()";
            resize = lua "hl.dsp.window.resize()";
            focusWorkspace = workspace: lua ''hl.dsp.focus({ workspace = "${workspace}" })'';
            hy3ChangeGroup = action: lua ''hl.plugin.hy3.change_group("${action}")'';
            hy3MakeGroup = lua ''hl.plugin.hy3.make_group("tab", { toggle = true })'';
            hy3FocusTab =
              direction: lua ''hl.plugin.hy3.focus_tab({ direction = "${direction}", wrap = true })'';
            hy3MoveWindow = direction: lua ''hl.plugin.hy3.move_window("${direction}")'';
            hyprexpo = lua ''function() hl.plugin.hyprexpo.expo("toggle") end'';
          };

          bind = key: dispatcher: opts: {
            _args = [
              key
              dispatcher
              opts
            ];
          };

          locked = {
            locked = true;
          };
          mod = key: dispatcher: bind (lua ''mainMod .. " + ${key}"'') dispatcher locked;

          switchBinds = map (
            i: mod (toString i) (dsp.exec "~/.config/hypr/workspace-manager.sh --switch ${toString i}")
          ) (lib.range 1 5);

          groupBinds = map (
            i:
            mod "SHIFT + ${toString i}" (
              dsp.exec "~/.config/hypr/workspace-manager.sh --set-group ${toString (i - 1)}"
            )
          ) (lib.range 1 5);

          moveBinds = map (
            i:
            mod "ALT + ${toString i}" (
              dsp.exec "~/.config/hypr/workspace-manager.sh --move-window ${toString i}"
            )
          ) (lib.range 1 5);

          moveGroupBinds = map (
            i:
            mod "ALT + SHIFT + ${toString i}" (
              dsp.exec "~/.config/hypr/workspace-manager.sh --move-to-group ${toString (i - 1)}"
            )
          ) (lib.range 1 5);

          speakerVolumeDown = ''if case "$(pactl get-default-sink)" in *Speaker*) true;; *) false;; esac; then L=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub(/%/,""); print $5}'); R=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub(/%/,""); print $12}'); R=$((R - 5)); [ "$R" -lt 0 ] && R=0; pactl set-sink-volume @DEFAULT_SINK@ "''${L}%" "''${R}%"; dunstify -u low -r 9910 "Volume: R ''${R}%"; else wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; dunstify -u low -r 9910 "Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')"; fi'';

          speakerVolumeUp = ''if case "$(pactl get-default-sink)" in *Speaker*) true;; *) false;; esac; then L=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub(/%/,""); print $5}'); R=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{gsub(/%/,""); print $12}'); R=$((R + 5)); [ "$R" -gt 100 ] && R=100; wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; pactl set-sink-volume @DEFAULT_SINK@ "''${L}%" "''${R}%"; dunstify -u low -r 9910 "Volume: R ''${R}%"; else wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; dunstify -u low -r 9910 "Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')"; fi'';
        in
        {
          wayland.windowManager.hyprland = {
            configType = "lua";
            enable = true;
            package = pkgs.hyprland;
            systemd.enable = true;
            systemd.variables = [ "--all" ];
            portalPackage = pkgs.xdg-desktop-portal-hyprland;
            plugins = [
              inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
              inputs.hy3.packages.${pkgs.system}.hy3
              inputs.hyprexpo.packages.${pkgs.system}.hyprexpo
            ];

            # ** General Settings
            settings = {
              # permission = "/usr/(bin|local/bin)/hyprpm, plugin, allow";

              mainMod._var = "SUPER";

              env = [
                {
                  _args = [
                    "GTK_THEME"
                    "Adwaita:dark"
                  ];
                }
              ];

              monitor = [
                {
                  output = "eDP-1";
                  mode = "2880x1800@60";
                  position = "0x0";
                  scale = "1.8";
                  bitdepth = 10;
                  cm = "hdr";
                }
                {
                  output = "eDP-2";
                  mode = "2880x1800@60";
                  position = "0x1000";
                  scale = "1.8";
                  bitdepth = 10;
                  cm = "hdr";
                } # Bottom monitor
                {
                  output = "";
                  mode = "preferred";
                  position = "auto";
                  scale = "1";
                } # For auto external monitors
              ];

              config = {
                general = {
                  gaps_in = 4;
                  gaps_out = 8;
                  border_size = 2;
                  col.inactive_border = "rgba(595959aa)";
                  allow_tearing = true;
                  layout = "hy3";
                  resize_on_border = true;
                  extend_border_grab_area = 30;
                };

                group.groupbar = {
                  # TODO add font weight, turn off when not in focus, gradients into hy3
                  # Or into native, borders
                  # Native tabstack vs plugin tab stacks
                  # Both missing: allow for tabs on the bottom
                  # Allow for app name first
                };

                decoration = {
                  dim_inactive = true;
                  dim_strength = 0.11;
                  shadow = {
                    enabled = false; # Battery hogs
                    range = 8;
                    render_power = 2;
                    color = "rgba(1a1a1aee)";
                  };
                  blur = {
                    enabled = false;
                    size = 5;
                    passes = 2;
                  };
                };

                animations.workspace_wraparound = true;
                dwindle.preserve_split = true;
                master.new_status = "master";

                # ** Bindings
                input = {
                  kb_options = "caps:escape, ctrl:swap_lalt_lctl";
                  # Testing this out
                  sensitivity = 1; # Clamped to 1
                  accel_profile = "flat";
                  repeat_delay = 180;
                  repeat_rate = 50;
                  # Allow for click and drag scrolling
                  # TODO Remove if not using the trackball
                  scroll_method = "on_button_down";
                  scroll_button = 275;
                  scroll_factor = 0.3;
                  touchpad = {
                    natural_scroll = true;
                    disable_while_typing = true;
                  };
                  # To prevent broken screen from creating inputs
                  touchdevice.enabled = false;
                };

                cursor.hide_on_key_press = true;

                misc = {
                  enable_swallow = true;
                  swallow_regex = "(org.wezfurlong.wezterm)";
                };

                # ** Plugins
                plugin = {
                  dynamic_cursors = {
                    enabled = true;
                    mode = "tilt";
                    tilt = {
                      activation = "quadratic";
                      window = 100;
                      limit = 1500;
                    };
                    shake.enabled = false;
                  };

                  hyprexpo = {
                    columns = 5;
                    gaps_in = 0;
                    gaps_out = 0;
                    bg_col = "rgb(000000)";
                    workspace_method = "center current";
                  };

                  hy3 = {
                    tab_first_window = true;
                    tabs = {
                      text_font = "Hermit";
                      text_height = 10;
                      border_width = 4;
                      colors = {
                        inactive = "rgba(595959DD)";
                        inactive_border = "rgba(2E3440FF)";
                        active = "rgba(5E81ACFF)";
                        active_border = "rgba(2E3440FF)";
                      };
                    };
                  };
                };
              };

              curve = [
                {
                  _args = [
                    "easeOutQuint"
                    {
                      type = "bezier";
                      points = lua "{ {0.23, 1}, {0.32, 1} }";
                    }
                  ];
                }
                {
                  _args = [
                    "easeInOutCubic"
                    {
                      type = "bezier";
                      points = lua "{ {0.65, 0.05}, {0.36, 1} }";
                    }
                  ];
                }
                {
                  _args = [
                    "linear"
                    {
                      type = "bezier";
                      points = lua "{ {0, 0}, {1, 1} }";
                    }
                  ];
                }
                {
                  _args = [
                    "almostLinear"
                    {
                      type = "bezier";
                      points = lua "{ {0.5, 0.5}, {0.75, 1} }";
                    }
                  ];
                }
                {
                  _args = [
                    "quick"
                    {
                      type = "bezier";
                      points = lua "{ {0.15, 0}, {0.1, 1} }";
                    }
                  ];
                }
                {
                  _args = [
                    "overshoot"
                    {
                      type = "bezier";
                      points = lua "{ {0.05, 0.9}, {0.1, 1.1} }";
                    }
                  ];
                }
              ];

              animation = [
                {
                  leaf = "global";
                  enabled = true;
                  speed = 10;
                  bezier = "default";
                }
                {
                  leaf = "windows";
                  enabled = true;
                  speed = 2.75;
                  bezier = "easeOutQuint";
                  style = "slide";
                }
                {
                  leaf = "fade";
                  enabled = true;
                  speed = 1.8;
                  bezier = "almostLinear";
                }
                {
                  leaf = "border";
                  enabled = true;
                  speed = 5.5;
                  bezier = "easeOutQuint";
                }
                {
                  leaf = "workspaces";
                  enabled = true;
                  speed = 2;
                  bezier = "easeOutQuint";
                  style = "slide";
                }

                # Disabled
                {
                  leaf = "windowsMove";
                  enabled = false;
                }
                {
                  leaf = "layers";
                  enabled = false;
                }
              ];

              #windowrule = [
              #  # "no_focus on, match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pinned false"
              #  "float on, match:title ^(Picture in picture)$"
              #  "pin on, match:title ^(Picture in picture)$"
              #  "size 200 200, match:title ^(Picture in picture)$"
              #  "move 1348 790, match:title ^(Picture in picture)$"
              #];

              window_rule = [
                {
                  match.title = "^(Picture in picture)$";
                  float = true;
                  pin = true;
                  size = "200 200";
                  move = "1348 790";
                }
              ];

              bind = [
                (bind "SUPER + H" (dsp.exec "wtype -k Left") { repeating = true; })
                (bind "SUPER + J" (dsp.exec "wtype -k Down") { repeating = true; })
                (bind "SUPER + K" (dsp.exec "wtype -k Up") { repeating = true; })
                (bind "SUPER + L" (dsp.exec "wtype -k Right") { repeating = true; })

                (mod "SPACE" (dsp.exec "wezterm"))
                # Screenshots
                (bind "ALT + SPACE" (dsp.exec "grimblast copy area") locked)
                # TODO For monitor screen keybindings, don't forget to update debug msg
                # One screen to svae power, two screen to use power
                (mod "B" (dsp.exec "~/.config/hypr/battery-saver.sh & "))
                (mod "SHIFT + B" (dsp.exec "~/.config/hypr/second-monitor.sh &"))
                # Just adding the commands would fail for some reason to execute the second mpvpaper command
                # Start the bottom monitor and start the wallpaper
                (mod "C" (dsp.exec "emacsclient -c --eval '(thanos/type)'"))
                (mod "V" (dsp.exec "~/.config/hypr/workspace-manager.sh --swap-monitors"))
                (mod "N" (dsp.exec "~/.config/hypr/workspace-manager.sh --debug"))
                (mod "W" dsp.close)
                (mod "M" dsp.exit)
                # Allow for the initial sleep
                (mod "comma" (dsp.exec "hyprlock"))
                (mod "period" dsp.hyprexpo)
                (mod "slash" (dsp.exec "~/.config/hypr/workspace-manager.sh --debug"))

                (mod "D" (dsp.hy3ChangeGroup "toggletab"))
                (mod "SHIFT + D" dsp.hy3MakeGroup)
                (mod "F" (dsp.hy3FocusTab "r"))
                (mod "S" (dsp.hy3FocusTab "l"))

                # "$mainMod, H, hy3:movefocus, l"
                # "$mainMod, L, hy3:movefocus, r"
                # "$mainMod, K, hy3:movefocus, u"
                # "$mainMod, J, hy3:movefocus, d"

                (mod "SHIFT + H" (dsp.hy3MoveWindow "left"))
                (mod "SHIFT + L" (dsp.hy3MoveWindow "right"))
                (mod "SHIFT + K" (dsp.hy3MoveWindow "up"))
                (mod "SHIFT + J" (dsp.hy3MoveWindow "down"))
              ]
              # TODO Create script for multimonitor support
              # TODO Add rename options to terminal
              # If both on monitor don't change,
              # If either not in monitor
              # Navigation (1-5) within current group
              ++ switchBinds
              # Group Selection (Mod + Shift + 1-5)
              ++ groupBinds
              # Move Window to Relative Workspace (Mod + Alt + 1-5)
              ++ moveBinds
              # Move Active Window to same slot in a different Group (Mod + Alt + Shift + 1-5)
              ++ moveGroupBinds
              ++ [
                (mod "mouse_down" (dsp.focusWorkspace "e+1"))
                (mod "mouse_up" (dsp.focusWorkspace "e-1"))

                # Probably should make a flag since this right only speaker is a asus laptop only issue
                # ", F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\" & "
                # ", F3, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ & wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\" & "
                (bind "F2" (dsp.exec speakerVolumeDown) locked)
                (bind "F3" (dsp.exec speakerVolumeUp) locked)
                (bind "F5" (dsp.exec "brightnessctl s 10%- & brightnessctl -d intel_backlight s 10%-") locked)
                (bind "F6" (dsp.exec "brightnessctl s 10%+ & brightnessctl -d intel_backlight s 10%+") locked)

                (bind "XF86AudioNext" (dsp.exec "playerctl next") locked)
                (bind "XF86AudioPause" (dsp.exec "playerctl play-pause") locked)
                (bind "XF86AudioPlay" (dsp.exec "playerctl play-pause") locked)
                (bind "XF86AudioPrev" (dsp.exec "playerctl previous") locked)
                (bind "XF86AudioLowerVolume" (dsp.exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") locked)
                (bind "XF86AudioRaiseVolume"
                  (dsp.exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
                  locked
                )
                (bind "XF86AudioMute" (dsp.exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") locked)
                (bind "XF86AudioMicMute" (dsp.exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") locked)
                (bind "XF86MonBrightnessUp" (dsp.exec "brightnessctl -e4 -n2 set 5%+") locked)
                (bind "XF86MonBrightnessDown" (dsp.exec "brightnessctl -e4 -n2 set 5%-") locked)

                # TODO Doesn't work since left is sent along with the ctrl
                # "CTRL, H, exec, wtype -k Left"
                # "CTRL, J, exec, wtype -k Down"
                # "CTRL, K, exec, wtype -k Up"
                # "CTRL, L, exec, wtype -k Right"

                (bind (lua ''mainMod .. " + mouse:272"'') dsp.drag { mouse = true; })
                (bind (lua ''mainMod .. " + mouse:273"'') dsp.resize { mouse = true; })
              ];
            };
          };
        };
    };
}
