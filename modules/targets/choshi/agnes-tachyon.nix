{ den, ... }:
{
  den.aspects.agnes-tachyon = {
    includes = [
      den.provides.define-user
      den.aspects.agnes-tachyon.provides.define-user
      den.provides.primary-user
      den.aspects.admin-identity
      den.aspects.documentation
      den.aspects.nix
      den.aspects.terminal
      den.aspects.font
      den.aspects.podman
      den.aspects.ssh
      den.aspects.pia-vpn
      den.aspects.agnes-tachyon.provides.tailscale
      den.aspects.agnes-tachyon.provides.security
    ];

    nixos = { ... }: {
      security.sudo.wheelNeedsPassword = false;
    };

    provides.define-user = { user, ... }: {
      nixos = { config, ... }: {
        environment.sessionVariables.HOME = config.users.users.${user.userName}.home;
        users.users.${user.userName}.description = "Agnes Tachyon";
      };
    };

    provides.security = {
      includes = [ den.aspects.security ];
      nixos = { config, ... }: {
        sops.secrets.immich-db-password = {
          key = "users/agnes-tachyon/immich-db-password";
          owner = "agnes-tachyon";
          mode = "0400";
        };

        sops.templates."immich.env" = {
          path = "/run/secrets-rendered/immich.env";
          owner = "agnes-tachyon";
          mode = "0400";

          content = ''
            DB_PASSWORD=${config.sops.placeholder."immich-db-password"}
          '';
        };

      };
    };

    provides.tailscale = {
      includes = [ den.aspects.tailscale ];
      nixos = { config, ... }: {
        systemd.services.tailscale-serve-jellyfin = {
          description = "Serve Jellyfin over Tailscale HTTPS";
          wantedBy = [ "multi-user.target" ];

          requires = [ "tailscaled.service" ];

          after = [
            "tailscaled.service"
            "tailscaled-autoconnect.service"
          ];

          serviceConfig = {
            Type = "simple";
            ExecStart = ''
              ${config.services.tailscale.package}/bin/tailscale serve \
                --https=443 --set-path=/jellyfin http://127.0.0.1:8096
            '';
            Restart = "always";
            RestartSec = "5s";
          };
        };

        systemd.services.tailscale-serve-hermes = {
          description = "Serve Hermes over Tailscale HTTPS";
          wantedBy = [ "multi-user.target" ];

          requires = [ "tailscaled.service" ];

          after = [
            "tailscaled.service"
            "tailscaled-autoconnect.service"
          ];

          serviceConfig = {
            Type = "simple";
            ExecStart = ''
              ${config.services.tailscale.package}/bin/tailscale serve \
                --https=443 --set-path=/hermes http://127.0.0.1:9119
            '';
            Restart = "always";
            RestartSec = "5s";
          };
        };
      };
    };
  };
}
