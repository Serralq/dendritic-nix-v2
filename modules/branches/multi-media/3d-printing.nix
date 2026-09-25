{ ... }:
{
  den.aspects.printing-3d = {
    homeManager =
      { pkgs, ... }:
      let
        bambu-appimage = import ../../_packages/bambu-appimage.nix { inherit pkgs; };
      in
      {
        home.packages = with pkgs; [
          freecad
          orca-slicer
          bambu-appimage # To send files to 3d printer w/ auth
          f3d # To preview in yazi my 3d models
          openscad-unstable # To have parametric model generator on my pc
        ];
      };
  };
}
