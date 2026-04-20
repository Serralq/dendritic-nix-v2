{ pkgs, lib, ... }:

{
  flake-file.inputs = {
    affinity-nix.url = "github:mrshmllow/affinity-nix";
  };

  den.aspects.photo = { config, ... }: {
    homeManager = { pkgs, inputs, ... }: {
      home.packages = with pkgs; [
        gimp3-with-plugins
        rawtherapee
        tagstudio # TagStudio
        inputs.affinity-nix.packages.${pkgs.system}.v3 # Affinity image editors
      ];
    };
  };
}
