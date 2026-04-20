{ pkgs, lib, ... }:

{
  den.aspects.container = { config, ... }: {
    nixos = { pkgs, ... }: {
      # ** Docker
      virtualisation.docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
      users.users.serralq.extraGroups = [ "docker" ];

      # ** Flatpak
      # To add repo:
      #   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      #
      # To install:
      # flatpak install flathub com.github.PintaProject.Pinta
      # also bambu studio
      services.flatpak.enable = true;
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        docker # Docker container
        lazydocker # Easier version of docker
        appimage-run # To run app images
      ];
    };
  };
}
