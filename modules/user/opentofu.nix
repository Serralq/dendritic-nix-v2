{ ... }:
{
  den.aspects.opentofu.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.opentofu ];
    };
}
