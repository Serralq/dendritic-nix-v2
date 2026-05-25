{ ... }:
{
  den.aspects.container =
    { user, ... }:
    {
      nixos =
        { pkgs, ... }:
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

          # * Waydroid
          # Currently only install diarium
          # sudo cp -r ./diarium_import.zip ~/.local/share/waydroid/data/media/0/Download
          # sudo waydroid init -s GAPPS -f # To get google apps, then follow wiki
          # Maybe in future add libhudini for arm support and download 学マス
          virtualisation.waydroid.enable = true;
          virtualisation.waydroid.package = pkgs.waydroid-nftables;
          environment.systemPackages = [ pkgs.wl-clipboard ]; # Enable clipboard sharing
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
