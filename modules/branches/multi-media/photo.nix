{ ... }:
{
  flake-file.inputs = {
    affinity-nix.url = "github:mrshmllow/affinity-nix";
    tagstudio.url = "github:TagStudioDev/TagStudio";
  };

  den.aspects.photo =
    { ... }:
    {
      homeManager =
        { pkgs, inputs, ... }:
        {
          home.packages = with pkgs; [
            gimp3-with-plugins
            rawtherapee
            tagstudio # TagStudio
            inputs.affinity-nix.packages.${pkgs.system}.v3 # Affinity image editors
          ];
        };
    };
}
