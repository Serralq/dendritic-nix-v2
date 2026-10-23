{ den, ... }:
{
  den.aspects.serralq = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      den.aspects.serralq.provides.define-user
      den.aspects.desktop-environment
      den.aspects.font
      den.aspects.documentation
      den.aspects.nix
      den.aspects.version-control
      den.aspects.ai
      den.aspects.languages
      den.aspects.terminal
      den.aspects.editors
      den.aspects.user-container
      den.aspects.podman
      den.aspects.opentofu
      den.aspects.browser
      den.aspects.gaming
      den.aspects.communication
      den.aspects.input-output
      den.aspects.file-management
      den.aspects.video
      den.aspects.photo
      den.aspects.printing-3d
      den.aspects.office
      den.aspects.remote
      den.aspects.reading
      den.aspects.ssh
      den.aspects.tailscale
      den.aspects.pia-vpn
      den.aspects.serralq.provides.security
    ];

    provides.security = {
      includes = [ den.aspects.security ];
      nixos = { ... }: {
        sops.secrets = {
          hcloud-token = {
            key = "users/serralq/hcloud-token";
            owner = "serralq";
            mode = "0400";
          };
          openrouter-token = {
            key = "users/serralq/openrouter-token";
            owner = "serralq";
            mode = "0400";
          };
        };
      };
    };

    provides.define-user = { user, ... }: {
      nixos = { config, ... }: {
        environment.sessionVariables.HOME = config.users.users.${user.userName}.home;
        users.users.${user.userName}.description = "Serralq";
      };
    };
  };

}
