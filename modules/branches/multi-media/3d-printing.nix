{ ... }:
{
  den.aspects.printing-3d = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          freecad
          orca-slicer
          f3d # To preview in yazi my 3d models
          openscad-unstable # To have parametric model generator on my pc
        ];
      };
  };
}
