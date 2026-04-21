# * Flakes
# For Flakes: since will be auto generated,
#   Flakes only work when tracked by git
# List of sources
# Follow just means imports not that it will accept public interface changes
# Flakes just means repoducable not that this version will work
# Nixpkgs-heavy: Whatever slows down the update by a lot
# Nixpkgs-stable: For stable version
#
# * Options
# Example: Add an option to ALL aspects (accessible via config.optName on any aspect)
# den.schema.aspect = { lib, ... }: {
#   options.minimal = lib.mkOption {
#     type = lib.types.bool;
#     default = false;
#   };
# };

# Example: Add an option to ALL hosts (accessible via host.optName on any host entity)
# den.schema.host.imports = [ { options.wsl = {
#   enable = lib.mkEnableOption "Enable WSL on this host";
#   module = lib.mkOption {
#     type = lib.types.deferredModule;
#     default = {};
#   };
# }; } ];

# Example: Add an option to ALL users (accessible via user.optName on any user entity)
# den.schema.user.imports = [ { options = {
#   email = lib.mkOption {
#     type = lib.types.str;
#     default = "";
#   };
# }; } ];
#
# * Global configs
{
  inputs,
  den,
  lib,
  ...
}:

let
  pkgs-stable = import inputs.nixpkgs-stable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  pkgs-heavy = import inputs.nixpkgs-heavy {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  # ** User declarations
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
  den.default.nixos.system.stateVersion = "25.05";
  den.default.homeManager.home.stateVersion = "25.05";

  den.hosts.x86_64-linux.hirakata.users.serralq = { };

  # ** Overlays
  den.aspects.overlays = { ... }: {
    nixos = { pkgs, ... }: {
      _module.args.inputs = inputs;

      imports = [
        inputs.copyparty.nixosModules.default
        inputs.sops-nix.nixosModules.sops
      ];

      nixpkgs.overlays = [
        # add the copyparty overlay to expose the package to the module
        inputs.copyparty.overlays.default
        # Overlay is for replacement or new keyword in global space
        #   with access to prev and final
        #   has a global eval order
        # Can either make a new pkg name or replace pkg
        # Aka I am the new maintainer, allow to seperate concerns
        (final: prev: {
          tagstudio = inputs.tagstudio.packages.${prev.system}.tagstudio-jxl.overrideAttrs (oldAttrs: {
            # Override is a regular build script keyword
            # Patches keyword is a part of nix stdenv
            patches = (oldAttrs.patches or [ ]) ++ [ ./../patches/tagstudio-nord.patch ];
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

      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
    };
  };

  # ** Flake-file inputs
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-heavy.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    copyparty.url = "github:9001/copyparty";
    tagstudio.url = "github:TagStudioDev/TagStudio";
    sops-nix.url = "github:Mic92/sops-nix";
    devenv.url = "github:cachix/devenv";
  };
}
