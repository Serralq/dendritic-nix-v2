{ den, ... }:
{
  den.aspects.desktop-environment = {
    includes = [
      den.aspects.desktop-scripts
      den.aspects.hyprland
    ];

    nixos =
      { pkgs, ... }:
      {

        # * Graphics
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
          ];
        };
        hardware.enableRedistributableFirmware = true;

        # * Enable the X11 windowing system and GNOME as backup
        services.xserver.enable = true;
        services.desktopManager.gnome.enable = true;
        services.displayManager.ly.enable = true;
        environment.sessionVariables.NIXOS_OZONE_WL = "1";

        # * Xdg portals
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
        lib,
        config,
        ...
      }:
      {
        # * Xdg termfilechooser config
        xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=yazi-wrapper.sh
          default_dir=$HOME
          env=TERMCMD='wezterm start --class "org.freedesktop.impl.portal.desktop.termfilechooser" --'
          open_mode=suggested
          save_mode=last
        '';

        # * Hyprland / DE / Keyboard-shortcuts
        home.packages = with pkgs; [
          wl-clipboard-x11 # To access clipboard from terminal
          libnotify # To test notification
          xeyes # Checking if using xwayland
          cliphist # Clipboard manager
          wl-clipboard
          ydotool
          grimblast # Better screenshots
          brightnessctl # For brightness cmd
          waybar # TODO create a currently listening
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
          waywallen # For desktop engine wallpapers
          mate-engine # For atri vr model to dance
          mission-center # Resource monitor
        ];

        # * Notifications: Dunst
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

        # * Hyprlock
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

        # * HyprIdle (handles locking + dim brightness on idle)
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              on_unlock_cmd = lib.concatStringsSep " " [
                "${config.home.homeDirectory}/.scripts/border-color.sh --all &"
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
      };
  };
}
