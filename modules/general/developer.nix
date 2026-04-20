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

    nixos = { pkgs, ... }: {
      documentation = {
        enable = true;
        man.enable = true;
        doc.enable = true;
        dev.enable = true;
        info.enable = true;
        nixos.enable = true;
      };
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        # Man pages
        man
        man-pages
        man-pages-posix
      ];
    };
  };
}
