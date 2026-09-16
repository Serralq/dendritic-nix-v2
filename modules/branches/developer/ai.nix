{ ... }:

{
  den.aspects.ai = {
    homeManager =
      { pkgs, ... }:
      {
        # Ai in terminal, each have different harness that they were trained on and optimized for
        home.packages = with pkgs; [
          claude-code
          # gemini-cli # Both suck ass
          codex # Only sucks within their own environment, use within opencode
          opencode
        ];
      };
  };
}
