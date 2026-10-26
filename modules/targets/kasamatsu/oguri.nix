{ den, ... }:
{
  den.aspects.oguri = {
    includes = [
      den.provides.define-user
      den.aspects.oguri.provides.define-user
      den.provides.primary-user
      den.aspects.admin-identity
      den.aspects.documentation
      den.aspects.nix
      den.aspects.terminal
      den.aspects.font
      den.aspects.podman
      den.aspects.ssh
    ];

    nixos = { ... }: {
      security.sudo.wheelNeedsPassword = false;
    };

    provides.define-user = { user, ... }: {
      nixos = { config, ... }: {
        environment.sessionVariables.HOME = config.users.users.${user.userName}.home;
        users.users.${user.userName}.description = "Oguri Cap";
      };
    };
  };
}
