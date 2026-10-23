{ den, ... }:
{
  den.aspects.nice-nature = {
    includes = [
      den.provides.define-user
      den.aspects.nice-nature.provides.nice-nature
      den.provides.primary-user
      den.aspects.admin-identity
      den.aspects.documentation
      den.aspects.nix
      den.aspects.terminal
      den.aspects.font
      den.aspects.podman
      den.aspects.ssh
      den.aspects.pia-vpn
      den.aspects.nice-nature.provides.tailscale
      den.aspects.nice-nature.provides.cloudflare
    ];

    nixos = { ... }: {
      security.sudo.wheelNeedsPassword = false;
    };

    provides.define-user = { user, ... }: {
      nixos = { config, ... }: {
        environment.sessionVariables.HOME = config.users.users.${user.userName}.home;
        users.users.${user.userName}.description = "Nice Nature";
      };
    };

    provides.cloudflare = { user, ... }: {
      includes = [
        den.aspects.security
        den.aspects.cloudflare
      ];
      nixos =
        { config, ... }:

        let
          secretName = "${user.userName}-cloudflared-credentials";
        in
        {
          # systemd LoadCredential supplies this root-owned secret to the dynamic service user.
          sops.secrets.${secretName}.key = "users/${user.userName}/cloudflared-credentials";

          services.cloudflared.tunnels."976a44e9-b2c2-4d1c-bd56-221a38342fcb" = {
            # Don't forget to set cloudflared tunnel route dns nixos-server <subdomain path>
            # Could follow future collectors but not right now
            ingress = {
              "tonda.serralq.dev" = "http://localhost:3210";
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
            # systemd LoadCredential supplies this root-owned secret to the dynamic service user.
            credentialsFile = config.sops.secrets.${secretName}.path;
          };
        };
    };

    provides.tailscale = {
      includes = [ den.aspects.tailscale ];
      nixos = { ... }: {
        services.tailscale = {
          useRoutingFeatures = "server";
          extraSetFlags = [ "--advertise-exit-node" ];
          openFirewall = true;
        };
      };
    };
  };
}
