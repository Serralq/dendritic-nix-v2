{ ... }:
{
  den.aspects.desktop-scripts =
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
          # ** VPN
          # Currently pia servers just suck and manually choosing servers also suck
          # systemd.services.vpn = {
          #   wantedBy = [ "multi-user.target" ];
          #   after = [ "network-online.target" ];
          #   wants = [ "network-online.target" ];
          #   serviceConfig = {
          #     Type = "simple";
          #     ExecStart = "${pkgs.openvpn}/bin/openvpn --config /run/secrets/openvpn-config --auth-user-pass /run/secrets/openvpn-auth";
          #     Restart = "on-failure";
          #   };
          # };
        };
      homeManager =
        {
          config,
          inputs,
          pkgs,
          ...
        }:
        let
          hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
        in
        {
          # * Hyprland session startup services
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

            # ** Clipboard history manager
            cliphist-store = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
                Restart = "on-failure";
              };
            };

            # ** Audio jack detection
            audio-jack = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                ExecStart = "${config.home.homeDirectory}/.config/hypr/audio-jack.sh";
                Restart = "on-failure";
              };
            };

            # ** Set cursor theme
            hyprland-cursor = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "oneshot";
                ExecStart = "${hyprland}/bin/hyprctl setcursor oguri-cap-1 50";
                RemainAfterExit = true;
              };
            };

            # ** Disable bottom monitor
            hyprland-monitor = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "oneshot";
                ExecStart = "${hyprland}/bin/hyprctl eval 'hl.monitor({ output = \"eDP-2\", disabled = true })'";
                RemainAfterExit = true;
              };
            };

            # ** Wallpaper
            # Allows for mouse tracking on transparent windows
            hyprland-wallpaper = {
              Unit.After = [ "hyprland-session.target" ];
              Install.WantedBy = [ "hyprland-session.target" ];
              Service = {
                Type = "simple";
                Environment = "WAYWALLEN_HYPRLAND_POINTER_CLASSES=org.wezfurlong.wezterm,emacs";
                ExecStart = "${pkgs.waywallen}/bin/waywallen --no-ui --display-backend layer-shell";
                Restart = "on-failure";
              };
            };

            # ** Restore saved workspaces (commented out: re-enable when needed)
            #       workspace-restore = {
            #         Unit.After = [ "hyprland-session.target" ];
            #         Install.WantedBy = [ "hyprland-session.target" ];
            #         Service = {
            #           Type = "oneshot";
            #           ExecStart = "${config.home.homeDirectory}/.config/hypr/workspace-manager.sh --restore";
            #           RemainAfterExit = true;
            #         };
            #       };

            # ** One monitor script (Use the manual method since this will default to battery saver) (commented out: re-enable when needed)
            #       one-monitor = {
            #         Unit.After = [ "hyprland-session.target" ];
            #         Install.WantedBy = [ "hyprland-session.target" ];
            #         Service = {
            #           Type = "oneshot";
            #           ExecStart = "${}/hypr/one-monitor.sh";
            #           RemainAfterExit = true;
            #         };
            #       };

          };

          # ** Japanese input method (launched via Hyprland to inherit session environment)
          wayland.windowManager.hyprland.extraConfig = ''
            hl.on("hyprland.start", function()
              hl.exec_cmd("${pkgs.fcitx5}/bin/fcitx5 -d")
            end)
          '';
        };
    };
}
