# Refactor: Move host-level aspects to user level + fix parametric issues

## Changes to apply

### 1. `modules/hosts/hirakata.nix` — slim down to host-only aspects

Remove hostname, define-user, primary-user, security, input-output from includes. Keep only overlays and systemd-bootloader.

```nix
    includes = [
      den.aspects.overlays
      den.aspects.systemd-bootloader
    ];
```

### 2. `modules/hosts/hirakata/serralq.nix` — add security, input-output, hostname

Add security, input-output, hostname to includes. Remove the duplicate define-user/primary-user that were in both host and user (already present here). Keep the { user, ... } parametric style with the simplified nixos/homeManager blocks.

```nix
{ den, ... }:
{
  den.aspects.serralq = { user, ... }: {
    includes = [
      den.provides.hostname
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "fish")
      den.aspects.security
      den.aspects.input-output
      den.aspects.browser
      den.aspects.gaming
      den.aspects.desktop-environment
      den.aspects.developer
      den.aspects.networking
      den.aspects.file-management
      den.aspects.multi-media
      den.aspects.startup-scripts
      den.aspects.communication
    ];

    nixos = { ... }: {
      users.users.${user.userName} = {
        description = "Serralq";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKHJOkxOS9XQmRSYT0olSv0LHfSF/xNA6n9y5+e1g/o alexanderngocdao@gmail.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKsOnJ1jLL3Ey8rVGRMdCUC0XDANQ1yJGxkU84XBi0M android-termux"
        ];
      };
    };

    homeManager = { ... }: {
      programs.home-manager.enable = true;
    };
  };
}
```

### 3. `modules/sops.nix` — revert to full { user, ... } parametric style

Remove the security-keyfile split. Make the whole security aspect parametric.

```nix
{ den, ... }:

{
  den.aspects.security = { user, ... }: {
    nixos = { ... }: {
# * SOPs
      sops.defaultSopsFile = ./../secrets/secrets.yaml;
      sops.defaultSopsFormat = "yaml";

      sops.secrets.tailscale-authkey = {};
      sops.secrets.cloudflared-credentials = {};

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
```

### 4. `modules/general/developer/nix.nix` — fix trusted-users bug

Change:
```
users.users.${user.userName}.extraGroups = [ "trusted" ];
```
To:
```
nix.settings.trusted-users = [ "root" user.userName ];
```