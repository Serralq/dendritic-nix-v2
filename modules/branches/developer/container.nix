{ ... }:
{
  den.aspects.container =
    { user, ... }:
    {
      nixos =
        { ... }:
        {
          # * Docker
          users.users.${user.userName}.extraGroups = [ "docker" ];
          virtualisation.docker = {
            enable = true;
            rootless = {
              enable = true;
              setSocketVariable = true;
            };
          };

          # * Flatpak
          # To add repo:
          #   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flhub.flatpakrepo
          #
          # To install:
          # flatpak install flathub com.github.PintaProject.Pinta
          # also bambu studio
          services.flatpak.enable = true;
        };

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            docker # Docker container
            lazydocker # Easier version of docker
            appimage-run # To run app images
          ];
        };
    };
}
