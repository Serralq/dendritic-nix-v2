{ pkgs, lib, ... }:

{
  den.aspects.editors = { config, ... }: {
    homeManager = { pkgs, ... }: {
      # Allow for zed acceleration
      targets.genericLinux.nixGL.vulkan.enable = true;

      home.packages = with pkgs; [
        emacs-pgtk # Main note taking, may require a doom install, only ver supporting wayland
        vips # For emacs dirvish
        pandoc # document convertions
        vscode # for VScode plugin's GUI
        zed-editor # Fast version of vs code
      ];

      # ** Emacs daemon
      systemd.user.services.emacs-daemon = {
        Unit.After = [ "hyprland-session.target" ];
        Install.WantedBy = [ "hyprland-session.target" ];
        Service = {
          Type = "forking";
          ExecStart = "${pkgs.emacs-pgtk}/bin/emacs --daemon";
          Restart = "on-failure";
        };
      };
    };
  };
}
