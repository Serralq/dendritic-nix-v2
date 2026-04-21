{ ... }:

{
  den.aspects.systemd-bootloader = { ... }: {
    nixos = { pkgs, ... }: {
      # * Bootleader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };
  };
}
