{ den, ... }:

{
  den.aspects.desktop-border-services =
    { user, ... }:
    {
      nixos =
        { pkgs, ... }:
        let
          # Refer to changing border color for more info
          border-color = pkgs.writeShellScript "border-color" ''
            ${pkgs.systemd}/bin/systemctl --machine=${user.userName}@.host --user start border-color
          '';
        in
        {

          # ** Customs: Mute after wake
          powerManagement.resumeCommands = ''
            ${pkgs.systemd}/bin/systemctl --machine=${user.userName}@.host --user start wakeup
          '';
          systemd.user.services.wakeup = {
            wantedBy = [ "default.target" ];
            after = [ "default.target" ];
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
    };

  den.aspects.desktop-scripts = { ... }: {
    homeManager = { config, pkgs, ... }: {
      # ** Hyprland session startup services
      systemd.user.services = {

        # ** Customs: Border colors
        border-color = {
          Unit.After = [ "hyprland-session.target" ];
          Install.WantedBy = [ "hyprland-session.target" ];
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.scripts/border-color.sh";
            RemainAfterExit = true;
          };
        };

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
            ExecStart = "${config.home.homeDirectory}/.config/hypr/audio-jack.sh";
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
            ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper eDP-1 ${config.home.homeDirectory}/Videos/atri.jpg -o '--loop --no-audio --fullscreen=yes --panscan=1'";
            Restart = "on-failure";
          };
        };

        # Restore saved workspaces (commented out: re-enable when needed)
        #       workspace-restore = {
        #         Unit.After = [ "hyprland-session.target" ];
        #         Install.WantedBy = [ "hyprland-session.target" ];
        #         Service = {
        #           Type = "oneshot";
        #           ExecStart = "${config.home.homeDirectory}/.config/hypr/workspace-manager.sh --restore";
        #           RemainAfterExit = true;
        #         };
        #       };

        # VPN
        vpn = {
          Unit.After = [ "hyprland-session.target" ];
          Install.WantedBy = [ "hyprland-session.target" ];
          Service = {
            Type = "simple";
            ExecStart = "${config.home.homeDirectory}/scripts/vpn";
            Restart = "on-failure";
          };
        };
        # One monitor script (Use the manual method since this will default to battery saver) (commented out: re-enable when needed)
        #       one-monitor = {
        #         Unit.After = [ "hyprland-session.target" ];
        #         Install.WantedBy = [ "hyprland-session.target" ];
        #         Service = {
        #           Type = "oneshot";
        #           ExecStart = "${}/hypr/one-monitor.sh";
        #           RemainAfterExit = true;
        #         };
        #       };

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
      };
    };
  };
}
