{ den, ... }:
{
  den.aspects.kasamatsu = {
    includes = [
      den.provides.hostname
      den.aspects.zfs
      den.aspects.systemd-bootloader
    ];

    nixos = { config, pkgs, ... }: {
      networking.hostId = "1f468a4b";
      disko.devices.disk.disk1.device = "/dev/disk/by-id/ata-SK_hynix_SC300_SATA_256GB_FJ6BN17501120BM38";

      # OptiPlex 7050 (Kaby Lake)
      boot.kernelModules = [ "kvm-intel" ];
      hardware.enableRedistributableFirmware = true;
      hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
      services.zfs.autoScrub.enable = true;

      # Optional: Quick Sync for Jellyfin/Immich transcoding
      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.intel-media-driver ];
      };
      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    };
  };
}
