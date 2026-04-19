{ den, ... }:
{
  den.aspects.serralq = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "fish")
      den.aspects.browser
      den.aspects.gaming
      den.aspects.desktop-environment
      den.aspects.developer
      den.aspects.container
      den.aspects.networking
    ];

    nixos = { pkgs, ... }: {
      # User
      # Define a user account. Don't forget to set a password with 'passwd'.
      users.users.serralq = {
        home = "/home/serralq";
        isNormalUser = true;
        description = "Serralq";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          # List of questions -> To check answer against
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKHJOkxOS9XQmRSYT0olSv0LHfSF/xNA6n9y5+e1g/o alexanderngocdao@gmail.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKsOnJ1jLL3Ey8rVGRMdCUC0XDANQ1yJGxkU84XBi0M android-termux"
        ];
      };

      environment.sessionVariables.HOME = "/home/serralq";
    };

    homeManager = { pkgs, ... }: {
      imports = [
        ./../../../home.nix
      ];

      home.username = "serralq";
      home.homeDirectory = "/home/serralq";
      home.stateVersion = "25.05"; # Please read the comment before changing.
      programs.home-manager.enable = true;
      # Allow for zed acceleration
      targets.genericLinux.nixGL.vulkan.enable = true;
    };
  };
}
