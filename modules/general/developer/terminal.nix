{ pkgs, lib, ... }:

{
  den.aspects.terminal = { config, ... }: {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        # * Terminal emulators
        wezterm # Terminal
        kitty # For testing + wayland

        # * Shell / Prompt
        neovim # Basic editor
        starship # Terminal prompt look
        fastfetch # Terminal splash screen
        yazi # File manager
        zoxide # Quick jump
        atuin # Terminal History
        pay-respects # Fixing previous terminal command
        fishPlugins.fifc # Fish auto completion fzf
        nushell # When I need structured contents
        carapace # Better terminal autocomplete

        # * CLI utilities
        bat # Better cat
        ripgrep # Greps but faster, written in Rust
        fzf # Fuzzy finder
        fd # A better find
        eza # Better ls
        mediainfo # Allow for more media preview in yazi
        ueberzugpp # For yazi image preview
        su-exec # Allow for switching user and then execute
        jc # JSON parser for stdout
        jq # JSON parser for stdout
      ];
    };
  };
}
