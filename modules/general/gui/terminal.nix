{ pkgs, lib, ... }:

{
  den.aspects.terminal = { config, ... }: {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        wezterm # Terminal
        kitty # For testing + wayland
      ];
    };
  };
}
