{ ... }:
{
  den.aspects.editors = {
    homeManager =
      { pkgs, ... }:
      {
        # Allow for zed acceleration
        targets.genericLinux.nixGL.vulkan.enable = true;

        home.packages = with pkgs; [
          emacs-pgtk # Main note taking, may require a doom install, only ver supporting wayland
          vips # For emacs dirvish
          pandoc # document convertions
          vscode # for VScode plugin's GUI
          zed-editor # Fast version of vs code
          todoist-electron # Notes app
        ];
      };
  };
}
