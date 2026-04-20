# * Header
{ pkgs, inputs, ... }:

{

  # * System Packages
  home.packages = with pkgs; [

    # * Terminal
    imagemagick # Edit image properties in the terminal
    ffmpeg # All media convertions
    sqlite # Sqlite
  ];
}
