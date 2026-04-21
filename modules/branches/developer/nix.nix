{ ... }:

{
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-alien.url = "github:thiagokokada/nix-alien";
    devenv.url = "github:cachix/devenv";
  };

  den.aspects.nix = { user, ... }: {
    nixos = { pkgs, inputs, ... }: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.permittedInsecurePackages = [
        "electron-36.9.5"
      ];
      nix.settings.trusted-users = [
        "root"
        user.userName
      ];

      # ** Flakes
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };

      # * Optimizations
      # ** Garbage collection
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      # ** Nix registry
      nix.registry = {
        nixpkgs-stable.flake = inputs.nixpkgs-stable;
        nixpkgs.flake = inputs.nixpkgs;
      };

      # ** Enable binaries in NixOS
      # # Allow for zed lsp servers
      programs.nix-ld.enable = true;
    };

    homeManager = { pkgs, inputs, ... }: {
      # ** Nix Packages
      home.packages = with pkgs; [
        devenv # Allows for custom env (inclu nightly rust)
        nix-tree # See size of nix
        nh # Better nix commands (rebuild, clean)
        nix-search-tv # Interactive search
        nix-your-shell # So nix develop goes into fish
        nix-index # To find missing binaries
        deadnix # Better nix config
        inputs.nix-alien.packages.${pkgs.system}.nix-alien # Running binaries in nix
      ];

      # ** Direnv
      programs = {
        direnv = {
          enable = true;
          enableFishIntegration = true; # see note on other shells below
          nix-direnv.enable = true;
        };
      };
    };
  };
}
