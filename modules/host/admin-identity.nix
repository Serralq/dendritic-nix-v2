{ ... }:
{
  den.aspects.admin-identity =
    { user, ... }:
    {
      nixos.users.users.${user.userName}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKHJOkxOS9XQmRSYT0olSv0LHfSF/xNA6n9y5+e1g/o alexanderngocdao@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKsOnJ1jLL3Ey8rVGRMdCUC0XDANQ1yJGxkU84XBi0M android-termux"
      ];
    };
}
