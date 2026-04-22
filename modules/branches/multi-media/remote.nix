{ ... }:
{
  flake-file.inputs = {
    parsecgaming.url = "github:DarthPJB/parsec-gaming-nix";
  };

  den.aspects.remote =
    { ... }:
    {
      homeManager =
        { pkgs, inputs, ... }:
        {
          home.packages = with pkgs; [
            inputs.parsecgaming.packages.${pkgs.system}.parsecgaming # Remote desktop
            freerdp # Remote desktop directly into windows container
          ];
        };
    };
}
