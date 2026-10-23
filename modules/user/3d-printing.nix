{ ... }:
{
  den.aspects.printing-3d = {
    homeManager =
      { pkgs, ... }:
      let
        orca-slicer-fixed = pkgs.orca-slicer.overrideAttrs (oldAttrs: {
          buildInputs = builtins.filter (input: input != pkgs.gcc-unwrapped) (oldAttrs.buildInputs or [ ]);
        });
      in
      {
        home.packages = with pkgs; [
          freecad
          orca-slicer-fixed # Current mainline opensource 3d printer slicer
          f3d # To preview in yazi my 3d models
          openscad-unstable # To have parametric model generator on my pc
        ];
      };
  };
}
