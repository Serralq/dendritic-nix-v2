{ ... }:
{
  den.aspects.user-container = {
    nixos =
      { pkgs, ... }:
      {
        # * Flatpak
        # To add repo:
        #   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flhub.flatpakrepo
        #
        # To install:
        # flatpak install flathub <url>
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
          appimage-run # To run app images
        ];
      };
  };
}
