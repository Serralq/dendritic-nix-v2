{ den, ... }:
{
  den.aspects.ssh = {
    includes = [
      den.aspects.networking
    ];
    nixos =
      { ... }:
      {
        # ** OpenSSH
        # 1) pkg install openssh
        # 2) ssh-keygen -t ed25519 -C "<name>" # Creates the answer
        # 3) cat ~/.ssh/id_ed25519.pub # Displays the matching public question
        # 4) ssh serralq@<YOUR-NIXOS-TAILSCALE-IP>
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
            KbdInteractiveAuthentication = false;
          };
        };
        networking.firewall.allowedTCPPorts = [ 22 ];
        programs.mosh.enable = true;
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          sshs # Nicer ssh config tui
          sshfs-fuse # For working over ssh eg yazi
          mosh # Allow for typing before response back in ssh
        ];
        programs.ssh = {
          enable = true;
          matchBlocks = {
            nice-nature = {
              hostname = "159.69.21.152";
              user = "nice-nature";
              identityFile = "~/.ssh/id_ed25519";
            };
            agnes-tachyon = {
              hostname = "37.27.245.194";
              user = "agnes-tachyon";
              identityFile = "~/.ssh/id_ed25519";
            };
          };
        };
      };
  };
}
