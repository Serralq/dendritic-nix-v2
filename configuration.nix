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

  # * User
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.serralq = {
    home = "/home/serralq";
    isNormalUser = true;
    description = "Serralq";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # List of questions -> To check answer against
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKHJOkxOS9XQmRSYT0olSv0LHfSF/xNA6n9y5+e1g/o alexanderngocdao@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOKsOnJ1jLL3Ey8rVGRMdCUC0XDANQ1yJGxkU84XBi0M android-termux"
    ];
  };

  # * Bootleader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # * Services
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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
    ];
  };
  hardware.enableRedistributableFirmware = true;

  # ** Security
  # *** Fail2Ban
  services.fail2ban.enable = true;

  # *** SOPS
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/serralq/.config/sops/age/keys.txt";

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

}
