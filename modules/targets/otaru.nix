{ den, ... }:
{
  den.aspects.otaru = {
    includes = [
      den.provides.hostname
      den.aspects.zfs
    ];

    nixos.networking.hostId = "72c9a4e1"; # Anything random for zfs
  };
}
