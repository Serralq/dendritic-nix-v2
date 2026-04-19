{ den, ... }:
{
  den.aspects.hirakata = {
    includes = [
      den.provides.hostname
      den.provides.define-user
      den.provides.primary-user
      den.aspects.overlays
    ];
    nixos = { ... }: {
      imports = [
        ./../../hardware-configuration.nix
        ./../../configuration.nix
      ];
    };
  };
}
