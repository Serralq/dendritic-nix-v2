{ inputs, ... }:
{
  flake-file.inputs.disko.url = "github:nix-community/disko";

  den.aspects.btrfs = {
    nixos = {
      imports = [ inputs.disko.nixosModules.disko ];

      services.btrfs.autoScrub = {
        enable = true;
        fileSystems = [ "/" ];
      };

      disko.devices.disk.disk1 = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              priority = 1;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              size = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
