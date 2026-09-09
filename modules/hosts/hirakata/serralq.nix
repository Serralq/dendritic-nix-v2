{ den, ... }:
{
  den.aspects.serralq =
    { ... }:
    {
      includes = [
        den.provides.define-user
        den.provides.primary-user
        # (den.provides.user-shell "fish")
        den.aspects.security
        den.aspects.input-output
        den.aspects.browser
        den.aspects.gaming
        den.aspects.desktop-environment
        den.aspects.developer
        den.aspects.networking
        den.aspects.file-management
        den.aspects.multi-media
        den.aspects.communication
      ];

      nixos =
        { ... }:
        {
          environment.sessionVariables.HOME = "/home/serralq";
          users.users.serralq = {
            description = "Serralq";
            # List of questions -> To check answer against
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKHJOkxOS9XQmRSYT0olSv0LHfSF/xNA6n9y5+e1g/o alexanderngocdao@gmail.com"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKsOnJ1jLL3Ey8rVGRMdCUC0XDANQ1yJGxkU84XBi0M android-termux"
            ];
          };
        };
    };
}
