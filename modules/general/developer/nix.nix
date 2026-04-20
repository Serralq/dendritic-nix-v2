{ pkgs, lib, ... }:

{
  flake-file.inputs = {
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  den.aspects.nix = { user, ... }: {
    nixos = { pkgs, inputs, ... }: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.permittedInsecurePackages = [
        "electron-36.9.5"
      ];
      users.users.${user.userName}.extraGroups = [ "trusted" ];

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
