{ den, ... }:
{
  den.aspects.hetzner = {
    includes = [
      den.aspects.grub
      den.aspects.ssh
    ];

    nixos = {
      boot.initrd.availableKernelModules = [
        "virtio_pci"
        "virtio_scsi"
        "virtio_blk"
        "ahci"
        "sd_mod"
      ];

      networking.useDHCP = false;
      networking.networkmanager.enable = false;

      services.cloud-init = {
        enable = true;
        network.enable = true;

        settings = {
          datasource_list = [ "Hetzner" ];
          preserve_hostname = true;

          cloud_init_modules = [ ];
          cloud_config_modules = [ ];
          cloud_final_modules = [ ];
        };
      };

    };
  };
}
