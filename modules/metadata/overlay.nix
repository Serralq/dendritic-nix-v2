# * Flakes
# For Flakes: since will be auto generated,
#             only work when tracked by git
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
  den,
  inputs,
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
  # ** Schema
  den.schema.conf.imports = [
    {
      options.externals = lib.mkOption {
        type = lib.types.path;
        default = inputs.self + /modules/_externals;
        description = "Directory containing non-nix files.";
      };
    }
  ];

  # ** User declarations
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
  den.default.nixos.nixpkgs.config.allowUnfree = true;
  den.default.nixos.system.stateVersion = lib.mkDefault "25.05";
  den.default.homeManager.home.stateVersion = "25.05";

  # Define a user account. Don't forget to set a password with 'passwd'.
  den.hosts.x86_64-linux.hirakata.users.serralq = { };
  den.hosts.x86_64-linux.otaru.users.nice-nature = { };
  den.hosts.x86_64-linux.choshi.users.agnes-tachyon = { };
  den.hosts.x86_64-linux.kasamatsu.users.oguri = { };

  # ** Overlays
  den.default.includes = [ den.aspects.overlays ];
  den.aspects.overlays = {
    includes = [ den.aspects.home-manager-backups ];

    nixos =
      { ... }:
      {
        _module.args.inputs = inputs;

        nixpkgs.overlays = [
          # Overlay is for replacement or new keyword in global space
          #   with access to prev and final
          #   has a global eval order
          # Can either make a new pkg name or replace pkg
          # Aka I am the new maintainer, allow to seperate concerns
          (final: prev: {
            # Custom packages
            waywallen = final.callPackage ../_packages/waywallen--gen { };

            mate-engine = final.callPackage ../_packages/mate-engine--gen { };

            opentabletdriver-drag-scroll =
              final.callPackage ../_packages/opentabletdriver-drag-scroll--gen/opentabletdriver-drag-scroll.nix
                { };

            # tagstudio = inputs.tagstudio.packages.${prev.system}.tagstudio-jxl.overrideAttrs (oldAttrs: {
            #   # Override is a regular build script keyword
            #   # Patches keyword is a part of nix stdenv
            #   patches = (oldAttrs.patches or [ ]) ++ [ ./../../patches/tagstudio-nord.patch ];
            # });

            # Custom nix stable pins, after fail in nix-unstable
            rarcrack = pkgs-stable.rarcrack;
            notonoto = pkgs-stable.notonoto;
            mokuro = pkgs-stable.mokuro;
            # This is not a namespace repalcement
            python-latest = pkgs-stable.python313;

            # Ensures this is replacement and not just new pkg name
            jetbrains = prev.jetbrains // {
              rust-rover = pkgs-heavy.jetbrains.rust-rover;
              clion = pkgs-heavy.jetbrains.clion;
              pycharm = pkgs-heavy.jetbrains.pycharm;
              idea = pkgs-heavy.jetbrains.idea;
              goland = pkgs-heavy.jetbrains.goland;
            };

          })
        ];

        # *** Home-manager
        home-manager.useGlobalPkgs = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
      };
  };

  # ** Flake-file inputs
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-heavy.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
  };
}
