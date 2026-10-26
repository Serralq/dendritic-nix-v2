{ den, ... }:
{
  den.aspects.numazu = {
    includes = [
      den.provides.hostname
      den.aspects.systemd-bootloader
      den.aspects.btrfs
    ];

    nixos = { ... }: {
      networking.hostId = "5f804d17";
      disko.devices.disk.disk1.device = "TO BE DETERMINED";
    };
  };
}
