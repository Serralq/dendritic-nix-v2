{ den, ... }:
{
  den.aspects.grub = { ... }: {
    nixos = { pkgs, ... }: {
      boot = {
        loader.grub.enable = true;
        initrd.services.lvm.enable = true;
      };
    };
  };
}
