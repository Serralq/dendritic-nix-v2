{ pkgs, lib, ... }:

{
  den.aspects.ai = { config, ... }: {
    homeManager = { pkgs, inputs, ... }: {
      # ** AI
      # Ai in terminal, each have different harness that they were trained on and optimized for
      home.packages = with pkgs; [
        claude-code
        gemini-cli
        codex
        opencode
        codeium # Ai autocomplete
        inputs.t3code.packages.${pkgs.system}.default # For t3code better threads
      ];
    };
  };
}
