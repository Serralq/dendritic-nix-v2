{ den, ... }:
{
  den.aspects.choshi = {
    includes = [
      den.provides.hostname
      den.aspects.hetzner
      den.aspects.zfs
    ];

    nixos.networking.hostId = "0ffa6d24"; # Anything random for zfs
  };
}
