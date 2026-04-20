{ den, ... }:

{
  den.aspects.security = { user, ... }: {
    nixos = { ... }: {
      # * SOPs
      sops.defaultSopsFile = ./../secrets/secrets.yaml;
      sops.defaultSopsFormat = "yaml";

      sops.secrets.tailscale-authkey = { };
      sops.secrets.cloudflared-credentials = { };

      sops.age.keyFile = "/home/${user.userName}/.config/sops/age/keys.txt";

      # * General Security
      security.polkit.enable = true;
      services.fail2ban.enable = true;
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        sops # To decrypt sops secrets
      ];
    };
  };
}
