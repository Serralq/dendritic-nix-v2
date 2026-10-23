{ ... }:
{
  den.aspects.docker = { user, ... }: {
    nixos = { ... }: {
      users.users.${user.userName}.extraGroups = [ "docker" ];

      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          docker
          lazydocker # Easier version of docker
        ];
      };
  };
}
