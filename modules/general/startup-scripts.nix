{ pkgs, ... }:

{
  den.aspects.startup-scripts =
    { user, ... }:
    let
      homeDir = "/home/${user.userName}";
    in
    {
      nixos =
        { pkgs, ... }:
        let
          border-color = pkgs.writeShellScript "border-color" ''
            ${pkgs.systemd}/bin/systemctl --machine=${user.userName}@.host --user start border-color
          '';
        in
        {
          # ** Customs: Border colors
          systemd.user.services.border-color = {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.bash}/bin/bash ${homeDir}/.scripts/border-color.sh";
            };
          };

          # ** Customs: Mute after wake
          powerManagement.resumeCommands = ''
            ${pkgs.systemd}/bin/systemctl --machine=${user.userName}@.host --user start wakeup
          '';
          systemd.user.services.wakeup = {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ 0%";
            };
          };

          # ** Power supply udev rules for border-color
          services.udev.extraRules = ''
            ACTION=="change",SUBSYSTEM=="power_supply", RUN+="${border-color}"
            SUBSYSTEM=="power_supply",ATTR{status}=="Discharging", RUN+="${border-color}"
          '';
        };

      # ** Hyprland session startup services
      homeManager =
        { config, pkgs, ... }:
        let
          hmHomeDir = config.home.homeDirectory;
        in
        {
          systemd.user.services = {
            # Clipboard history manager
            cliphist-store = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
                Restart = "on-failure";
              };
            };

            # Audio jack detection
            audio-jack = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${hmHomeDir}/.config/hypr/audio-jack.sh";
                Restart = "on-failure";
              };
            };

            # Set cursor theme
            hyprland-cursor = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "oneshot";
                ExecStart = "${pkgs.hyprland}/bin/hyprctl setcursor oguri-cap-1 50";
                RemainAfterExit = true;
              };
            };

            # Disable bottom monitor
            hyprland-monitor = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "oneshot";
                ExecStart = "${pkgs.hyprland}/bin/hyprctl keyword monitor eDP-2,disable";
                RemainAfterExit = true;
              };
            };

            # Wallpaper
            hyprland-wallpaper = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper eDP-1 ${hmHomeDir}/Videos/atri.jpg -o '--loop --no-audio --fullscreen=yes --panscan=1'";
                Restart = "on-failure";
              };
            };

            # Restore saved workspaces
            workspace-restore = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "oneshot";
                ExecStart = "${hmHomeDir}/.config/hypr/workspace-manager.sh --restore";
                RemainAfterExit = true;
              };
            };

            # VPN
            vpn = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${hmHomeDir}/scripts/vpn";
                Restart = "on-failure";
              };
            };

            # Emacs daemon
            emacs-daemon = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "forking";
                ExecStart = "${pkgs.emacs-pgtk}/bin/emacs --daemon";
                Restart = "on-failure";
              };
            };

            # Japanese input method (also started by i18n.inputMethod.fcitx5)
            fcitx5 = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "forking";
                ExecStart = "${pkgs.fcitx5}/bin/fcitx5 -d";
                Restart = "on-failure";
              };
            };

            # Copyparty file server
            copyparty-user = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${pkgs.copyparty}/bin/copyparty -c ${hmHomeDir}/.config/copyparty/copyparty.conf";
                Restart = "on-failure";
              };
            };

            # Remote disk mount
            rclone-mount = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${pkgs.rclone}/bin/rclone mount --vfs-cache-mode writes --dir-cache-time 5s nixos-dav: ${hmHomeDir}/Remote-Disk/";
                Restart = "on-failure";
              };
            };

            # # One monitor script (Use the manual method since this will default to battery saver)
            #       one-monitor = {
            #         Unit.After = [ "hyprland-session.target" ];
            #         Install.WantedBy = [ "hyprland-session.target" ];
            #         Service = {
            #           Type = "oneshot";
            #           ExecStart = "${hmHomeDir}/hypr/one-monitor.sh";
            #           RemainAfterExit = true;
            #         };
            #       };

            # # Mkdocs service (interal: dump, external: blog)
            #       mkdocs = {
            #         Unit.After = [ "hyprland-session.target" ];
            #         Install.WantedBy = [ "hyprland-session.target" ];
            #         Service = {
            #           Type = "simple";
            #           ExecStart = let
            #             mkdocs-build = pkgs.writeShellScript "mkdocs-build-serve" ''
            #               ${pkgs.mkdocs}/bin/mkdocs build && ${pkgs.mkdocs}/bin/mkdocs serve
            #             '';
            #           in "${mkdocs-build}";
            #           WorkingDirectory = "${hmHomeDir}/Ririka/.attach/17/d5b658-4543-4a30-b9a5-5e046f4b3e4c/Norn";
            #           Restart = "on-failure";
            #         };
            #       };
          };
        };
    };
}
