{ ... }:
{
  den.aspects.grub =
    { ... }:
    {
      nixos =
        { ... }:
        {
          boot = {
            loader.grub.enable = true;
            initrd.services.lvm.enable = true;
          };
        };
    };
}
