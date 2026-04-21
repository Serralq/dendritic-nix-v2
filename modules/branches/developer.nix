{ den, ... }:

{
  # Necessary for nix and container
  den.aspects.developer = { config, ... }: {
    includes = [
      den.aspects.nix
      den.aspects.version-control
      den.aspects.ai
      den.aspects.languages
      den.aspects.terminal
      den.aspects.editors
      den.aspects.container
      den.aspects.sqlite
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
        btop # Resource monitor
        # Man pages
        man
        man-pages
        man-pages-posix
      ];
    };
  };
}
