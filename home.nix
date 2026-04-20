{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    sqlite # Sqlite
  ];
}
