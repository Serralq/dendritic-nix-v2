{ ... }:
{
  den.aspects.sqlite =
    { ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            sqlite
          ];
        };
    };
}
