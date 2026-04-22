{ ... }:
{
  den.aspects.font =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          # Adding regular and JP fonts
          # console.font = "Hermit";
          console.keyMap = "us";
          fonts.packages = with pkgs; [
            hermit # Monospace font
            comfortaa # Easy on the eye font
            ipafont # JP fonts
            kochi-substitute # JP fonts
            nerd-fonts.dejavu-sans-mono
            julia-mono
            nerd-fonts.iosevka
            symbola
            notonoto
          ];
          i18n.inputMethod = {
            enable = true;
            type = "fcitx5";
            fcitx5.addons = with pkgs; [
              fcitx5-mozc
              fcitx5-mozc-ut
              fcitx5-gtk
              fcitx5-nord
            ];
          };
          # Configure keymap in X11
          services.xserver.xkb = {
            layout = "us";
            variant = "";
          };
          # Select internationalisation properties.
          i18n.defaultLocale = "en_US.UTF-8";
          i18n.extraLocaleSettings = {
            LC_ADDRESS = "en_US.UTF-8";
            LC_IDENTIFICATION = "en_US.UTF-8";
            LC_MEASUREMENT = "en_US.UTF-8";
            LC_MONETARY = "en_US.UTF-8";
            LC_NAME = "en_US.UTF-8";
            LC_NUMERIC = "en_US.UTF-8";
            LC_PAPER = "en_US.UTF-8";
            LC_TELEPHONE = "en_US.UTF-8";
            LC_TIME = "en_US.UTF-8";
          };
        };

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            hermit # Font
            nerd-fonts.dejavu-sans-mono
            nerd-fonts.iosevka
            symbola
            notonoto
            julia-mono
            kdePackages.fcitx5-configtool # Setting up Jp IME
          ];
        };
    };
}
