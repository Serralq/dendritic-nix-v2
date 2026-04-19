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
      den.aspects.version-control
      den.aspects.ai
      den.aspects.languages
    ];
  };
}
