{ inputs, ... }:

{
  den.aspects.security = {
    nixos = { ... }: {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      # * SOPs
      sops.defaultSopsFile = ./../secrets/secrets.yaml;
      sops.defaultSopsFormat = "yaml";
      sops.age.keyFile = "/home/serralq/.config/sops/age/keys.txt";

      sops.secrets.tailscale-authkey = { };
      sops.secrets.cloudflared-credentials = { };

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
