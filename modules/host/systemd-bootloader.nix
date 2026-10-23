{ ... }:
{
  den.aspects.systemd-bootloader = {
    nixos =
      { ... }:
      {
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
      };
  };
}
