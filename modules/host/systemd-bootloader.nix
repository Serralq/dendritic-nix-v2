{ ... }:
{
  den.aspects.systemd-bootloader = {
    nixos =
      { ... }:
      {
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };
  };
}
