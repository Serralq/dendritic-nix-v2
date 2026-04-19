{
  pkgs,
  den,
  lib,
  ...
}:

{
  den.aspects.developer = { config, ... }: {
    includes = [
      den.aspects.nix
    ];
  };
}
