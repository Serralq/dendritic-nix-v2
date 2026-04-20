{ lib, ... }:

{
  den.aspects.sqlite = { config, ... }: {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          sqlite
        ];
      };
  };
}
