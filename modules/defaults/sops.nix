# * Workflow
# - Encrypt: file +format
# - Decrypt: key into empty var or echo $envar
#   - Nix: empty variable
# - Edit: use sops <file> to edit it
{ ... }:
{
  den.aspects.security =
    { user, ... }:
    {
      flake-file.inputs = {
        sops-nix.url = "github:Mic92/sops-nix";
      };

      nixos =
        { ... }:
        {
          sops.defaultSopsFile = ./../../secrets/secrets.yaml;
          sops.defaultSopsFormat = "yaml";

          sops.secrets.tailscale-authkey = { };
          sops.secrets.cloudflared-credentials = { };

          sops.age.keyFile = "/home/${user.userName}/.config/sops/age/keys.txt";

          security.polkit.enable = true;
          services.fail2ban.enable = true;
        };

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            sops # To decrypt sops secrets
          ];
        };
    };
}
