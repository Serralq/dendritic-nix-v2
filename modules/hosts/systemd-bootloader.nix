{ ... }:

{
  den.aspects.systemd-bootloader = { ... }: {
    nixos = { ... }: {
      # * Bootleader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };
  };
}
