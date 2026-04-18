# [[file:../nixos.org::*Build( browser.nix )][Build( browser.nix ):1]]
{ pkgs, ... }:

{
  # Build( browser.nix ):1 ends here

  # [[file:../nixos.org::*Build( browser.nix )][Build( browser.nix ):2]]
  home.packages = with pkgs; [
    brave # Ad-blocking
    google-chrome # Compadibility
    vivaldi # Main browser
    # TODO remove per window workspace, only have regular workspace
    # Allow for jump between tab stacks
  ];
  # Build( browser.nix ):2 ends here

  # [[file:../nixos.org::*Build( browser.nix )][Build( browser.nix ):3]]
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=yazi-wrapper.sh
    default_dir=$HOME
    env=TERMCMD='wezterm start --class "org.freedesktop.impl.portal.desktop.termfilechooser" --'
    open_mode=suggested
    save_mode=last
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Web content
      "text/html" = "vivaldi-stable.desktop";
      "application/xhtml+xml" = "vivaldi-stable.desktop";
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";
      "x-scheme-handler/ftp" = "vivaldi-stable.desktop";

      # Images
      "image/jpeg" = "vivaldi-stable.desktop";
      "image/png" = "vivaldi-stable.desktop";
      "image/gif" = "vivaldi-stable.desktop";
      "image/webp" = "vivaldi-stable.desktop";
      "image/svg+xml" = "vivaldi-stable.desktop";
      "image/bmp" = "vivaldi-stable.desktop";
      "image/tiff" = "vivaldi-stable.desktop";

      # Documents
      "application/pdf" = "vivaldi-stable.desktop";
      "application/xml" = "vivaldi-stable.desktop";
      "text/xml" = "vivaldi-stable.desktop";
      "text/plain" = "vivaldi-stable.desktop";
    };
  };
  # Build( browser.nix ):3 ends here

  # [[file:../nixos.org::*Build( browser.nix )][Build( browser.nix ):4]]
}
# Build( browser.nix ):4 ends here
