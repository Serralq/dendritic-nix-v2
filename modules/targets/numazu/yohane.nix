{ den, inputs, ... }:
{
  flake-file.inputs.jovian = {
    url = "github:Jovian-Experiments/Jovian-NixOS";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.yohane = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      den.aspects.yohane.provides.define-user
      den.aspects.admin-identity
      den.aspects.yohane.provides.desktop-environment
      den.aspects.font
      den.aspects.nix
      den.aspects.browser
      den.aspects.yohane.provides.gaming
      den.aspects.communication
      den.aspects.input-output
      den.aspects.file-management
      den.aspects.remote
      den.aspects.ssh
      # den.aspects.tailscale
      # den.aspects.pia-vpn
    ];

    provides.desktop-environment = {
      nixos = { ... }: {
        services.desktopManager.gnome.enable = true;
      };
    };
    provides.gaming = { user, ... }: {
      includes = [ den.aspects.gaming ];
      nixos = { ... }: {
        imports = [ inputs.jovian.nixosModules.default ];
        jovian.devices.steamdeck.enable = true;
        jovian.steam = {
          enable = true;
          autoStart = true;
          user = user.userName;
          desktopSession = "gnome";
        };
      };
    };
    provides.define-user = { user, ... }: {
      nixos = { config, ... }: {
        environment.sessionVariables.HOME = config.users.users.${user.userName}.home;
        users.users.${user.userName}.description = "Yohane";
      };
    };
  };

}
