# [[file:nixos.org::*Let variables][Let variables:1]]
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
  # Let variables:1 ends here

  # [[file:nixos.org::*Imports][Imports:1]]
  imports = [
    ./hardware-configuration.nix
  ];
  # Imports:1 ends here

  # [[file:nixos.org::*User][User:1]]
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
  # User:1 ends here

  # [[file:nixos.org::*Bootloader][Bootloader:1]]
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Bootloader:1 ends here

  # [[file:nixos.org::*Networking][Networking:1]]
  # Hostname
  networking.hostName = "nixos";
  # Enable networking
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "America/New_York";
  # Allow ssh ports
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  # Networking:1 ends here

  # [[file:nixos.org::*Packages, and clean up][Packages, and clean up:1]]
  # List packages installed in system profile. To search, run:
  # Was missing in home-manager
  environment.systemPackages = with pkgs; [
  ];

  # Home manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "serralq" = import ./home.nix;
    };
    useGlobalPkgs = true; # allows for unfree in homemanager too
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Adding flakes
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

  # Removing old system builds
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # Packages, and clean up:1 ends here

  # [[file:nixos.org::*Insecure packages][Insecure packages:1]]
  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
  ];
  # Insecure packages:1 ends here

  # [[file:nixos.org::*Registry info][Registry info:1]]
  nix.registry = {
    nixpkgs-stable.flake = inputs.nixpkgs-stable;
    nixpkgs.flake = inputs.nixpkgs;
  };
  # Registry info:1 ends here

  # [[file:nixos.org::*Fonts and IME][Fonts and IME:1]]
  # Adding regular and JP fonts
  # console.font = "Hermit";
  console.keyMap = "us";
  fonts.packages = with pkgs; [
    hermit # Monospace font
    comfortaa # Easy on the eye font
    ipafont # JP fonts
    kochi-substitute # JP fonts
    nerd-fonts.dejavu-sans-mono
    julia-mono
    nerd-fonts.iosevka
    symbola
    notonoto
  ];
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-mozc-ut
      fcitx5-gtk
      fcitx5-nord
    ];
  };
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  # Fonts and IME:1 ends here

  # [[file:nixos.org::*Enable split keyboard controls][Enable split keyboard controls:1]]
  # Include voyager rules
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
  # Enable split keyboard controls:1 ends here

  # [[file:nixos.org::*Customs: Border colors][Customs: Border colors:1]]
  systemd.user.services.border-color = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /home/serralq/.scripts/border-color.sh";
    };
  };
  # Customs: Border colors:1 ends here

  # [[file:nixos.org::*Customs: Mute after wake][Customs: Mute after wake:1]]
  # Mute after waking up
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl --machine=serralq@.host --user start wakeup
  '';
  systemd.user.services.wakeup = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ 0%";
    };
  };
  # Customs: Mute after wake:1 ends here

  # [[file:nixos.org::*Auto launch tailscale][Auto launch tailscale:1]]
  # Automatically startup tailscale
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

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
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
  # Auto launch tailscale:1 ends here

  # [[file:nixos.org::*SSH][SSH:1]]
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  # SSH:1 ends here

  # [[file:nixos.org::*Printing][Printing:1]]
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Printing:1 ends here

  # [[file:nixos.org::*Pulse audio][Pulse audio:1]]
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # Pulse audio:1 ends here

  # [[file:nixos.org::*Tailscale / Networking][Tailscale / Networking:1]]
  # Enable tailscale
  services.tailscale = {
    enable = true;
  };
  # Tailscale / Networking:1 ends here

  # [[file:nixos.org::*Window manager][Window manager:1]]
  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  environment.sessionVariables = {
    HOME = "/home/serralq";
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
    ];
  };
  hardware.enableRedistributableFirmware = true;

  # Enable the X11 windowing system and GNOME as backup
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;

  # Login Manager
  services.displayManager.ly.enable = true;
  # Window manager:1 ends here

  # [[file:nixos.org::*Docker][Docker:1]]
  # Enable docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  # Docker:1 ends here

  # [[file:nixos.org::*Documentation / also in packages /][Documentation // also in packages //:1]]
  # Add documentation
  documentation = {
    enable = true;
    man.enable = true;
    doc.enable = true;
    dev.enable = true;
    info.enable = true;
    nixos.enable = true;
  };
  # Documentation // also in packages //:1 ends here

  # [[file:nixos.org::*Flatpak][Flatpak:1]]
  services.flatpak.enable = true;
  # Flatpak:1 ends here

  # [[file:nixos.org::*Steam][Steam:1]]
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    protontricks.enable = true;
  };
  programs.gamemode.enable = true;
  # Steam:1 ends here

  # [[file:nixos.org::*Fail2Ban][Fail2Ban:1]]
  services.fail2ban.enable = true;
  # Fail2Ban:1 ends here

  # [[file:nixos.org::*Sops][Sops:1]]
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/serralq/.config/sops/age/keys.txt";
  # Sops:1 ends here

  # [[file:nixos.org::*Cloudflared][Cloudflared:1]]
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
  # Cloudflared:1 ends here

  # [[file:nixos.org::*OBS-studio][OBS-studio:1]]
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
  # OBS-studio:1 ends here

  # [[file:nixos.org::*Xdg-port][Xdg-port:1]]
  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-termfilechooser
    ];

    config = {
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
      common = {
        default = [ "gtk" ];
      };
    };
  };
  # Xdg-port:1 ends here

  # [[file:nixos.org::*Allow for binaries][Allow for binaries:1]]
  # Allow for zed lsp servers
  programs.nix-ld.enable = true;
  # Allow for binaries:1 ends here

  # [[file:nixos.org::*Class specific services][Class specific services:1]]
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  # Class specific services:1 ends here

  # [[file:nixos.org::*Footer + stateVersion][Footer + stateVersion:1]]
  system.stateVersion = "25.05"; # Did you read the comment?
}
# Footer + stateVersion:1 ends here
