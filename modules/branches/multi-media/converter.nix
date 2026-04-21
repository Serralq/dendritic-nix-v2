{ ... }:

{
  den.aspects.converter = { ... }: {
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
