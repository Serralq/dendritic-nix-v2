{ ... }:
{
  den.aspects.networking =
    {
      user,
      ...
    }:
    {
      nixos =
        { config, pkgs, ... }:
        {

          # * Networking
          networking.networkmanager.enable = true;
          time.timeZone = "America/New_York";
          networking.firewall.enable = true;
          # Allow ssh ports
          networking.firewall.allowedTCPPorts = [ 22 ];

          # ** Auto launch tailscale
          # make sure tailscale is running before trying to connect to tailscale
          services.tailscale.enable = true;
          systemd.services.tailscale-autoconnect = {
            description = "Automatic connection to Tailscale";

            after = [
              "network-pre.target"
              "tailscale.service"
            ];
            wants = [
              "network-pre.target"
              "tailscale.service"
            ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig.Type = "oneshot";

            script = with pkgs; ''
              # wait for tailscaled to settle
              sleep 2

              # check if we are already authenticated to tailscale
              status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
              if [ $status = "Running" ]; then # if so, then do nothing
                exit 0
              fi


              # otherwise authenticate with tailscale
              ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets.tailscale-authkey.path})
            '';
          };

          # ** OpenSSH
          # 1) pkg install openssh
          # 2) ssh-keygen -t ed25519 -C "<name>" # Creates the answer
          # 3) cat ~/.ssh/id_ed25519.pub # Displays the matching public question
          # 4) ssh serralq@<YOUR-NIXOS-TAILSCALE-IP>
          services.openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = false;
              PermitRootLogin = "no";
            };
          };

          # ** Cloudflared
          systemd.services.cloudflared-tunnel-976a44e9-b2c2-4d1c-bd56-221a38342fcb = {
            serviceConfig = {
              User = user.userName;
              Group = "users";
            };
          };
          services.cloudflared = {
            enable = true;
            tunnels = {
              "976a44e9-b2c2-4d1c-bd56-221a38342fcb" = {
                credentialsFile = config.sops.secrets.cloudflared-credentials.path;
                # Don't forget to set cloudflared tunnel route dns nixos-server <subdomain path>
                ingress = {
                  "copyparty.serralq.dev" = "http://localhost:3210";
                  "tonda.serralq.dev" = "http://localhost:3210";
                  "mkdocs.serralq.dev" = "http://localhost:8000";
                  "jellyfin.serralq.dev" = "http://localhost:8096";
                  "saku.serralq.dev" = "http://localhost:8096";
                  "immich.serralq.dev" = "http://localhost:2283";
                  "noa.serralq.dev" = "http://localhost:2283";
                  "doom.serralq.dev" = "https://localhost:8080";
                  "roxy.serralq.dev" = "http://localhost:8080";
                  # Placeholders so it's pre-partitioned
                  "one.serralq.dev" = "http://localhost:8080";
                  "two.serralq.dev" = "http://localhost:8080";
                  "three.serralq.dev" = "http://localhost:8080";
                  "four.serralq.dev" = "http://localhost:8080";
                  "five.serralq.dev" = "http://localhost:8080";
                };
                default = "http_status:404";
              };
            };
          };
        };

      # ** Regular packages
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            openvpn # VPN use
            cloudflared # Allow for external links
            sshfs # For working over ssh eg yazi
            wireshark # Better network inspection
            termshark
            sshs # Nicer ssh config tui
          ];
          # ** Mkdocs
          # Mkdocs blog service (commented out: re-enable when needed)
          #       systemd.user.services.mkdocs-serve = {
          #         Unit.After = [ "hyprland-session.target" ];
          #         Install.WantedBy = [ "hyprland-session.target" ];
          #         Service = {
          #           Type = "simple";
          #           ExecStart = "${pkgs.bash}/bin/bash -c 'cd /home/serralq/Ririka/.attach/17/d5b658-4543-4a30-b9a5-5e046f4b3e4c/Norn && ${pkgs.mkdocs}/bin/mkdocs build && ${pkgs.mkdocs}/bin/mkdocs serve'";
          #           WorkingDirectory = "/home/serralq/Ririka/.attach/17/d5b658-4543-4a30-b9a5-5e046f4b3e4c/Norn";
          #           Restart = "on-failure";
          #         };
          #       };
          #
        };
    };
}
