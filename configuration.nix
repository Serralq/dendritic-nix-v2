# * Header
{
  config,
  pkgs,
  inputs,
  ...
}:

let
  # Refer to changing border color for more info
  border-color = pkgs.writeShellScript "border-color" ''
    ${pkgs.systemd}/bin/systemctl --machine=serralq@.host --user start border-color
  '';
in
{
  environment.sessionVariables.HOME = "/home/serralq";
  system.stateVersion = "25.05"; # Did you read the comment?

  # * Imports
  imports = [
    ./hardware-configuration.nix
  ];
  environment.systemPackages = with pkgs; [
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];

  # ** Flakes
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "serralq"
    ];
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  # * User
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.serralq = {
    home = "/home/serralq";
    isNormalUser = true;
    description = "Serralq";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      # List of questions -> To check answer against
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKHJOkxOS9XQmRSYT0olSv0LHfSF/xNA6n9y5+e1g/o alexanderngocdao@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKsOnJ1jLL3Ey8rVGRMdCUC0XDANQ1yJGxkU84XBi0M android-termux"
    ];
  };

  # * Bootleader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # * Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  # Allow ssh ports
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # * Optimizations
  # ** Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ** Nix registry
  nix.registry = {
    nixpkgs-stable.flake = inputs.nixpkgs-stable;
    nixpkgs.flake = inputs.nixpkgs;
  };

  # * System.d
  # ** Enable custom keyboards (voyager)
  services.udev.extraRules = ''
    ACTION=="change",SUBSYSTEM=="power_supply", RUN+="${border-color}"
    SUBSYSTEM=="power_supply",ATTR{status}=="Discharging", RUN+="${border-color}"

    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
      # Rule for all ZSA keyboards
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
      # Rule for the Moonlander
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
      # Rule for the Ergodox EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
      # Rule for the Planck EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Wally Flashing rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  # ** Customs: Border colors
  systemd.user.services.border-color = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /home/serralq/.scripts/border-color.sh";
    };
  };

  # ** Customs: Mute after wake
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl --machine=serralq@.host --user start wakeup
  '';
  systemd.user.services.wakeup = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ 0%";
    };
  };

  # ** Auto launch tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
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
      ${tailscale}/bin/tailscale up -authkey tskey-examplekeyhere
    '';
  };

  # * Services
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
    };
  };

  # ** Printing
  services.printing.enable = true;

  # ** Pulse audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ** Tailscale / Networking
  services.tailscale.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
    ];
  };
  hardware.enableRedistributableFirmware = true;

  # ** Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # ** Documentation
  documentation = {
    enable = true;
    man.enable = true;
    doc.enable = true;
    dev.enable = true;
    info.enable = true;
    nixos.enable = true;
  };

  # ** Flatpak
  # To add repo:
  #   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  #
  # To install:
  # flatpak install flathub com.github.PintaProject.Pinta
  # also bambu studio
  services.flatpak.enable = true;

  # ** Security
  # *** Fail2Ban
  services.fail2ban.enable = true;

  # *** SOPS
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/serralq/.config/sops/age/keys.txt";

  # ** Cloudflared
  services.cloudflared = {
    enable = true;
    tunnels = {
      "976a44e9-b2c2-4d1c-bd56-221a38342fcb" = {
        credentialsFile = "/home/serralq/.cloudflared/976a44e9-b2c2-4d1c-bd56-221a38342fcb.json";
        # Don't forget to set cloudflared tunnel route dns nixos-server <subdomain path>
        ingress = {
          "copyparty.serralq.dev" = "http://localhost:3210";
          "tonda.serralq.dev" = "http://localhost:3210";
          "mkdocs.serralq.dev" = "http://localhost:8000";
          "jellyfin.serralq.dev" = "http://localhost:8096";
          "saku.serralq.dev" = "http://localhost:8096";
          "immich.serralq.dev" = "http://localhost:2283";
          "noa.serralq.dev" = "http://localhost:2283";
          "doom.serralq.dev" = "https://localhost:8080";
          "roxy.serralq.dev" = "http://localhost:8080";
          # Placeholders so it's pre-partitioned
          "one.serralq.dev" = "http://localhost:8080";
          "two.serralq.dev" = "http://localhost:8080";
          "three.serralq.dev" = "http://localhost:8080";
          "four.serralq.dev" = "http://localhost:8080";
          "five.serralq.dev" = "http://localhost:8080";
        };
        default = "http_status:404";
      };
    };
  };
  systemd.services.cloudflared-tunnel-976a44e9-b2c2-4d1c-bd56-221a38342fcb = {
    serviceConfig = {
      User = "serralq";
      Group = "user";
    };
  };

  # ** OBS-studio
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;

  # ** Enable binaries in NixOS
  # Allow for zed lsp servers
  programs.nix-ld.enable = true;
}
