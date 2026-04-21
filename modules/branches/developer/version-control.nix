{ ... }:

{
  den.aspects.version-control = { ... }: {
    homeManager = { pkgs, ... }: {
      # ** Git/JJ
      home.packages = with pkgs; [
        stow # Manage dot files
        git # Track files
        gh # Github specific commands
        git-filter-repo # Remove from history
        github-desktop # Way to check in a GUI
        difftastic # For better git syntax highlight
        lazygit # TUI for git file tree exploration
        jujutsu # Better git?
        jj-starship
        jjui # another jj tui
      ];
    };
  };
}
