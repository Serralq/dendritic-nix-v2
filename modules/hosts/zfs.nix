{ inputs, ... }:
{
  flake-file.inputs = {
    disko.url = "github:nix-community/disko";
  };

  den.aspects.zfs = {
    nixos =
      { lib, ... }:
      {
        imports = [ inputs.disko.nixosModules.disko ];

        # Required for ZFS — must match your actual hostname
        # generate with: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '
        networking.hostId = lib.mkDefault "8c3b74a7";

        boot.supportedFilesystems = [ "zfs" ];
        boot.zfs.forceImportRoot = false;

        disko.devices = {
          disk.disk1 = {
            device = lib.mkDefault "/dev/sda";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {

                # Keep for Hetzner dedicated bare-metal compatibility
                boot = {
                  name = "boot";
                  size = "10M";
                  type = "EF02";
                };

                esp = {
                  name = "ESP";
                  size = "4G";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };

                zfs = {
                  name = "zfs";
                  size = "100%";
                  content = {
                    type = "zfs";
                    pool = "zroot";
                  };
                };
              };
            };
          };

          zpool.zroot = {
            type = "zpool";

            options = {
              ashift = "12"; # 4K sectors — set once, never changeable
              autotrim = "on"; # good practice even on HDDs, essential on SSDs
            };

            rootFsOptions = {
              compression = "zstd"; # ~1.5–2x space savings on NixOS store, minimal CPU cost
              "com.sun:auto-snapshot" = "false"; # manage snapshots explicitly
              mountpoint = "none"; # pool root is never mounted directly
              xattr = "sa"; # store xattrs in inodes — faster for the Nix store
              acltype = "posixacl"; # required by systemd
            };

            datasets = {

              # Nix store — the biggest win from ZFS compression on NixOS
              "local/nix" = {
                type = "zfs_fs";
                options = {
                  mountpoint = "legacy";
                  "com.sun:auto-snapshot" = "false"; # nix store is fully reproducible
                };
                mountpoint = "/nix";
              };

              # Root — kept small, snapshottable
              "local/root" = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/";
              };

              # Persistent state you want to snapshot (databases, app data, etc.)
              "safe/home" = {
                type = "zfs_fs";
                options = {
                  mountpoint = "legacy";
                  "com.sun:auto-snapshot" = "true";
                };
                mountpoint = "/home";
              };

              "safe/persist" = {
                type = "zfs_fs";
                options = {
                  mountpoint = "legacy";
                  "com.sun:auto-snapshot" = "true";
                };
                mountpoint = "/persist";
              };
              "local/reserved" = {
                type = "zfs_fs";
                options = {
                  mountpoint = "none";
                  refreservation = "10G"; # Replace with 10% of your actual disk size (e.g., 50G for a 500GB drive)
                  "com.sun:auto-snapshot" = "false";
                };
              };
            };
          };
        };
      };
  };
}
