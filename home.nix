# * Header
{ pkgs, inputs, ... }:

{

  # * System Packages
  home.packages = with pkgs; [
    libnotify # To test notification

    # * Terminal
    imagemagick # Edit image properties in the terminal
    xeyes # Checking if using xwayland
    ffmpeg # All media convertions
    sqlite # Sqlite
    wl-clipboard-x11 # To access clipboard from terminal
    xdg-desktop-portal-termfilechooser # Yazi as file chooser
  ];
}
