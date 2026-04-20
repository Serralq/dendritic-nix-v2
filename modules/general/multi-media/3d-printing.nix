{ lib, ... }:

{
  den.aspects.printing-3d = { config, ... }: {
    homeManager =
      { pkgs, ... }:
      let
        bambu-appimage = import ../../_nixos/bambu-appimage.nix { inherit pkgs; };
      in
      {
        home.packages = with pkgs; [
          freecad
          orca-slicer
          bambu-appimage
        ];
      };
  };
}
