{ ... }:
{
  den.aspects.documentation = {
    nixos =
      { ... }:
      {
        documentation = {
          enable = true;
          man.enable = true;
          doc.enable = true;
          dev.enable = true;
          info.enable = true;
          nixos.enable = true;
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          btop # Resource monitor
          # Man pages
          man
          man-pages
          man-pages-posix
        ];
      };
  };
}
