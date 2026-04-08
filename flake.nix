# [[file:nixos.org::*Build( flake.nix )][Build( flake.nix ):1]]
# TODO sort which worth it in config or home.nix
{
  description = "Main Config";

  # List of sources
  # Follow just means imports not that it will accept public interface changes
  # Flakes just means repoducable not that this version will work
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # Whatever slows down the update by a lot
    nixpkgs-heavy.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # For stable version
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.52.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.52.0";
      inputs.hyprland.follows = "hyprland";
    };

    hy3 = {
      url = "github:outfoxxed/hy3/hl0.52.0";
      inputs.hyprland.follows = "hyprland";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors/8c1679b87c54e97145cae83e622956d720e88bef";
      inputs.hyprland.follows = "hyprland";
    };

    affinity-nix.url = "github:mrshmllow/affinity-nix";

    copyparty.url = "github:9001/copyparty";

    parsecgaming.url = "github:DarthPJB/parsec-gaming-nix";

    winapps.url = "github:Insomniac66/winapps-nixos-fix";

    nix-alien.url = "github:thiagokokada/nix-alien";

    tagstudio.url = "github:TagStudioDev/TagStudio";

    sops-nix.url = "github:Mic92/sops-nix";

    t3code.url = "github:rodeyseijkens/t3code-nix";

    devenv.url = "github:cachix/devenv";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-heavy,
      home-manager,
      copyparty,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-heavy = import nixpkgs-heavy {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.default
          copyparty.nixosModules.default
          sops-nix.nixosModules.sops
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              # add the copyparty overlay to expose the package to the module
              copyparty.overlays.default

              # Overlay is for replacement or new keyword in global space
              #   with access to prev and final
              #   has a global eval order
              # Can either make a new pkg name or replace pkg
              # Aka I am the new maintainer, allow to seperate concerns
              (final: prev: {

                tagstudio = inputs.tagstudio.packages.${prev.system}.tagstudio-jxl.overrideAttrs (oldAttrs: {
                  # Override is a regular build script keyword
                  # Patches keyword is a part of nix stdenv
                  patches = (oldAttrs.patches or [ ]) ++ [ ./patches/tagstudio-nord.patch ];
                });

                hyprland = inputs.hyprland.packages.${prev.system}.hyprland;
                xdg-desktop-portal-hyprland = inputs.hyprland.packages.${prev.system}.xdg-desktop-portal-hyprland;

                # Custom nix stable pins, after fail in nix-unstable
                rarcrack = pkgs-stable.rarcrack;

                # Ensures this is replacement and not just new pkg name
                jetbrains = prev.jetbrains // {
                  rust-rover = pkgs-heavy.jetbrains.rust-rover;
                  clion = pkgs-heavy.jetbrains.clion;
                  pycharm = pkgs-heavy.jetbrains.pycharm;
                  idea = pkgs-heavy.jetbrains.idea;
                  goland = pkgs-heavy.jetbrains.goland;
                };

                # This is not a namespace repalcement
                python-latest = pkgs.python313;
              })
            ];
          })
        ];
      };
    };
}
# Build( flake.nix ):1 ends here
