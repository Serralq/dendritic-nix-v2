{ ... }:
{
  den.aspects.grub = {
    nixos =
      { ... }:
      {
        boot = {
          loader.grub.enable = true;
        };
      };
  };
}
