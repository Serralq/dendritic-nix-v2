# * Header
{ pkgs, inputs, ... }:

{

  # * System Packages
  home.packages = with pkgs; [
    libnotify # To test notification

    # * Terminal
    jq # Parse stdout
    ripgrep # Greps but faster, written in Rust
    btop # Resource monitor
    fzf # Fuzzy finder
    fd # A better find
    eza # Better ls
    wordnet # For offline emacs dictionary
    ispell # For emacs to stop giving errors
    imagemagick # Edit image properties in the terminal
    xeyes # Checking if using xwayland
    ffmpeg # All media convertions
    jc # JSON parser for stdout
    jq # JSON parser for stdout
    pandoc # document convertions
    mediainfo # Allow for more media preview in yazi
    sqlite # Sqlite
    wl-clipboard-x11 # To access clipboard from terminal
    bat # Better cat
    su-exec # Allow for switching user and then execute
    vips # For emacs dirvish
    ueberzugpp # For yazi image preview
    xdg-desktop-portal-termfilechooser # Yazi as file chooser
    texliveSmall

    # * DevOps
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

  ];
}
