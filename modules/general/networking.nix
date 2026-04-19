{ pkgs, lib, ... }:

{
  den.aspects.networking = { config, ... }: {
    nixos = { pkgs, ... }: {
      # * Networking
      networking.hostName = "nixos";
      networking.networkmanager.enable = true;
      time.timeZone = "America/New_York";
      # Allow ssh ports
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 22 ];

      users.users.serralq.extraGroups = [ "networkmanager" ];

      # ** Auto launch tailscale
      systemd.services.tailscale-autoconnect = {
        description = "Automatic connection to Tailscale";

        # make sure tailscale is running before trying to connect to tailscale
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
          ${tailscale}/bin/tailscale up -authkey tskey-examplekeyhere
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

      # ** Tailscale / Networking
      services.tailscale.enable = true;

      # ** Cloudflared
      services.cloudflared = {
        enable = true;
        tunnels = {
          "976a44e9-b2c2-4d1c-bd56-221a38342fcb" = {
            credentialsFile = "/home/serralq/.cloudflared/976a44e9-b2c2-4d1c-bd56-221a38342fcb.json";
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
      systemd.services.cloudflared-tunnel-976a44e9-b2c2-4d1c-bd56-221a38342fcb = {
        serviceConfig = {
          User = "serralq";
          Group = "user";
        };
      };
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        openvpn # VPN use
        cloudflared # Allow for external links
        rclone # For file transfers
        sshfs # For working over ssh eg yazi
      ];
    };
  };
}
