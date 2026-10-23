{ den, ... }:
{
  den.aspects.tailscale =
    { user, ... }:
    {
      includes = [
        den.aspects.security
        den.aspects.networking
      ];
      nixos =
        { config, pkgs, ... }:

        let
          secretName = "${user.userName}-tailscale-authkey";
        in
        {
          sops.secrets.${secretName}.key = "users/${user.userName}/tailscale-authkey";
          services.tailscale = {
            enable = true;
            authKeyFile = config.sops.secrets.${secretName}.path;
          };
          # ** Auto launch tailscale
          # make sure tailscale is running before trying to connect to tailscale
          systemd.services.tailscale-autoconnect = {
            description = "Automatic connection to Tailscale";

            after = [
              "network-pre.target"
              "tailscale.service"
            ];
            wants = [
              "network-pre.target"
              "tailscale.service"
            ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig.Type = "oneshot";

            script = with pkgs; ''
              # wait for tailscaled to settle
              sleep 2

              # check if we are already authenticated to tailscale
              status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
              if [ $status = "Running" ]; then # if so, then do nothing
                exit 0
              fi


              # otherwise authenticate with tailscale
              ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets.${secretName}.path})
            '';
          };
        };
    };
}
