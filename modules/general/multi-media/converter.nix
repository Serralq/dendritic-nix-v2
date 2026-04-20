{ lib, ... }:

{
  den.aspects.converter = { config, ... }: {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          imagemagick # Edit image properties in the terminal
          ffmpeg # All media convertions
        ];
      };
  };
}
