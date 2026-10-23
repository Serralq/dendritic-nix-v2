# Explaining each block in zfs.nix

**Session ID:** ses_e988bc76dffejP1fslw33dl37q
**Created:** 10/23/2026, 2:30:32 AM
**Updated:** 10/23/2026, 2:46:46 AM

---

## User

Read my @modules/host/zfs.nix and explain to me what each block is doing

---

## Assistant

**Tool: skill**

---

## Assistant

**Tool: glob**

**Tool: grep**

---

## Assistant

This module defines a **reusable, single-disk ZFS layout** using Disko. It creates a boot partition, an EFI partition, and a ZFS pool named `zroot`, with separate datasets for `/`, `/nix`, `/home`, and `/persist`.

Here is what each block does, in file order.

### 1. Module Wrapper And Disko Input
[`modules/host/zfs.nix:1`](modules/host/zfs.nix#L1)

```nix
{ inputs, ... }:
{
  flake-file.inputs.disko.url = "github:nix-community/disko";
```

- `{ inputs, ... }:` declares a Nix module function that receives `inputs` and tolerates other arguments.
- `flake-file.inputs.disko.url` declares Disko as a flake dependency through your flake-file setup.
- Disko lets you describe disks, partitions, filesystems, and pools declaratively.

**Declaring this layout does not itself wipe your disk.** Running Disko's provisioning/formatting operations against it can.

### 2. Reusable ZFS Aspect
[`modules/host/zfs.nix:5`](modules/host/zfs.nix#L5)

```nix
den.aspects.zfs = {
  nixos =
    { lib, ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];
```

This defines a Den aspect named `zfs`. Hosts that include `den.aspects.zfs` receive the NixOS configuration inside it.

The inner module receives `lib`, Nixpkgs' utility library, and imports Disko's NixOS module so options such as `disko.devices` become available.

Your `choshi` and `otaru` target modules both include this aspect.

### 3. ZFS Host Identity
[`modules/host/zfs.nix:10`](modules/host/zfs.nix#L10)

```nix
networking.hostId = lib.mkDefault "8c3b74a7";
```

ZFS uses this eight-digit hexadecimal ID to identify the machine importing a pool. It helps guard against importing a pool that appears to belong to another host.

`lib.mkDefault` makes this a fallback: a normal assignment in a host module overrides it. Your `choshi` and `otaru` targets already provide their own IDs.

**The comment saying it “must match your actual hostname” is incorrect.** It is not the hostname or necessarily derived from it. It should be stable and unique per host.

### 4. Boot-Time ZFS Support
[`modules/host/zfs.nix:14`](modules/host/zfs.nix#L14)

```nix
boot.supportedFilesystems = [ "zfs" ];
boot.zfs.forceImportRoot = false;
```

- Enables the NixOS integration needed to use ZFS, including boot support.
- Disables forcibly importing the root pool.

With `forceImportRoot = false`, ZFS can refuse to import a pool that appears to be active on another machine. This is safer, but moving a pool between machines or recovering from some unclean shutdown situations may require manual intervention.

### 5. Disk And Partition Table
[`modules/host/zfs.nix:17`](modules/host/zfs.nix#L17)

```nix
disko.devices = {
  disk.disk1 = {
    device = lib.mkDefault "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
```

Defines a logical disk named `disk1`, backed by `/dev/sda` unless a host overrides it, with a GPT partition table.

`disk1` is just Disko's configuration name, not a Linux device name.

For an actual installation, a stable path such as `/dev/disk/by-id/...` is generally safer than `/dev/sda`, whose identity can change with device enumeration.

### 6. BIOS Boot Partition
[`modules/host/zfs.nix:25`](modules/host/zfs.nix#L25)

```nix
boot = {
  name = "boot";
  size = "10M";
  type = "EF02";
};
```

Creates a 10 MiB BIOS boot partition.

`EF02` identifies the GPT partition type used by GRUB for legacy BIOS booting. It has no filesystem and is not mounted anywhere.

This reserves space for BIOS compatibility, including the Hetzner bare-metal use case mentioned in the comment. **It does not configure or install GRUB by itself.**

### 7. EFI System Partition
[`modules/host/zfs.nix:32`](modules/host/zfs.nix#L32)

```nix
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
```

Creates a 4 GiB EFI System Partition:

- `EF00` marks it as an ESP.
- `vfat` provides the FAT filesystem used for UEFI boot files.
- `/boot` is where NixOS mounts it.

The partition can hold bootloader files, kernels, and initrds, depending on your bootloader setup. The bootloader itself must be configured elsewhere.

### 8. ZFS Partition
[`modules/host/zfs.nix:43`](modules/host/zfs.nix#L43)

```nix
zfs = {
  name = "zfs";
  size = "100%";
  content = {
    type = "zfs";
    pool = "zroot";
  };
};
```

Allocates the remaining disk space to a partition that becomes a member of `zroot`.

This is **one disk with no mirror or RAID redundancy**. ZFS can detect corruption using checksums, but this layout generally cannot repair damaged user data from another copy on a different disk.

### 9. Pool-Level Settings
[`modules/host/zfs.nix:55`](modules/host/zfs.nix#L55)

```nix
zpool.zroot = {
  type = "zpool";

  options = {
    ashift = "12";
    autotrim = "on";
  };
```

Defines the pool and its pool-level properties.

| Setting | Meaning |
|---|---|
| `ashift = "12"` | Uses a minimum sector allocation size of 2¹² bytes, or 4096 bytes. A common choice for modern drives. It is effectively fixed for the vdev once created. |
| `autotrim = "on"` | Automatically issues discard/TRIM requests for freed space when the underlying storage supports them. Useful primarily for SSDs and thin-provisioned storage. |

The comment calling TRIM “essential” on SSDs is stronger than necessary. It is useful, but not a requirement for correctness.

### 10. Inherited Dataset Defaults
[`modules/host/zfs.nix:63`](modules/host/zfs.nix#L63)

```nix
rootFsOptions = {
  compression = "zstd";
  "com.sun:auto-snapshot" = "false";
  mountpoint = "none";
  xattr = "sa";
  acltype = "posixacl";
};
```

These properties are set on the pool's root dataset, `zroot`. Descendant datasets inherit them unless overridden.

| Setting | Meaning |
|---|---|
| `compression = "zstd"` | Transparently compresses data. Actual savings depend on the data; already-compressed files may gain little. |
| `"com.sun:auto-snapshot" = "false"` | Sets a user property that compatible snapshot tools can use to exclude datasets from automatic snapshots. |
| `mountpoint = "none"` | Prevents the pool's root dataset itself from being mounted as a directory. |
| `xattr = "sa"` | Stores extended attributes using ZFS system attributes, often reducing overhead compared with separate attribute objects. |
| `acltype = "posixacl"` | Enables POSIX access-control lists, supporting software and services that use finer-grained permissions. |

**The auto-snapshot property does not schedule snapshots.** It is metadata for a separately configured snapshot service.

### 11. Nix Store Dataset
[`modules/host/zfs.nix:73`](modules/host/zfs.nix#L73)

```nix
"local/nix" = {
  type = "zfs_fs";
  options = {
    mountpoint = "legacy";
    "com.sun:auto-snapshot" = "false";
  };
  mountpoint = "/nix";
};
```

Creates `zroot/local/nix` and mounts it at `/nix`.

Two different mountpoint settings appear here:

- `options.mountpoint = "legacy"` tells ZFS not to manage the mount using its native mount mechanism.
- Disko's `mountpoint = "/nix"` generates the NixOS filesystem configuration so NixOS manages that mount instead.

This contains all of `/nix`, not just `/nix/store`, including Nix's database and other state.

It inherits Zstd compression and explicitly opts out of compatible automatic snapshot policies. That opt-out repeats the inherited default, making the intention explicit.

### 12. Root Dataset
[`modules/host/zfs.nix:83`](modules/host/zfs.nix#L83)

```nix
"local/root" = {
  type = "zfs_fs";
  options.mountpoint = "legacy";
  mountpoint = "/";
};
```

Creates `zroot/local/root`, mounted at `/`.

Separating `/nix`, `/home`, and `/persist` keeps their contents outside root-dataset snapshots. Other directories, such as `/etc` and `/var`, remain on this root dataset unless configured separately.

Despite the comment “kept small,” there is no quota limiting its size.

**Nothing here resets root on boot.** This is an ordinary persistent root filesystem unless another module implements rollback or impermanence.

### 13. Home Dataset
[`modules/host/zfs.nix:90`](modules/host/zfs.nix#L90)

```nix
"safe/home" = {
  type = "zfs_fs";
  options = {
    mountpoint = "legacy";
    "com.sun:auto-snapshot" = "true";
  };
  mountpoint = "/home";
};
```

Creates `zroot/safe/home`, mounted at `/home`.

It overrides the inherited snapshot property to `true`, marking user data for snapshot tools that honor that property.

The names `safe` and `local` are organizational dataset paths. They have **no built-in ZFS behavior**: `safe` does not automatically mean backed up or redundant.

### 14. Persistent-State Dataset
[`modules/host/zfs.nix:100`](modules/host/zfs.nix#L100)

```nix
"safe/persist" = {
  type = "zfs_fs";
  options = {
    mountpoint = "legacy";
    "com.sun:auto-snapshot" = "true";
  };
  mountpoint = "/persist";
};
```

Creates `zroot/safe/persist`, mounted at `/persist`, also marked for compatible snapshot tools.

This provides a separate place to store application state, databases, or data preserved across root rollbacks.

**It does not automatically move any data there.** Services, bind mounts, or an impermanence configuration must explicitly use `/persist`.

### 15. Reserved Free Space
[`modules/host/zfs.nix:108`](modules/host/zfs.nix#L108)

```nix
"local/reserved" = {
  type = "zfs_fs";
  options = {
    mountpoint = "none";
    refreservation = "10G";
    "com.sun:auto-snapshot" = "false";
  };
};
```

Creates an unmounted dataset that reserves 10 GiB of pool space.

The purpose is to keep normal datasets from consuming every last byte. If the pool gets critically full, you can reduce or remove the reservation to recover some working space.

- `mountpoint = "none"` means there is no directory to write into.
- `refreservation = "10G"` reserves capacity for this dataset, making it unavailable to others.
- Snapshot exclusion is explicit.

The comment recommends changing it to roughly 10% of disk capacity, but **the actual configuration is a fixed 10 GiB**, not a percentage.

### Resulting Layout

```text
/dev/sda                         Default device; overridable
├── BIOS boot partition          10 MiB, unformatted
├── EFI System Partition         4 GiB, FAT, mounted at /boot
└── ZFS partition                Remaining space
    └── zroot                    Single-disk pool
        ├── local/nix            /nix
        ├── local/root           /
        ├── local/reserved       Unmounted, reserves 10 GiB
        ├── safe/home            /home
        └── safe/persist         /persist
```

All these ZFS datasets share the pool's available capacity; they are not fixed-size partitions. The notable omissions from this file are **snapshot scheduling, backups, encryption, bootloader configuration, and root rollback**. Those would need to be configured elsewhere.

---

## User

If I wanted a minimal zfs install for nixos, what would you change?

---

## Assistant

**Tool: skill**

---

## Assistant

**Tool: read**

**Tool: read**

**Tool: grep**

---

## Assistant

For a **fresh install**, I would reduce this to **one ZFS pool, one root dataset, and the boot partitions your hardware needs**. Separate datasets are useful for different snapshot or rollback policies, but NixOS does not require them.

**What I Would Change**
| Current block | Recommendation |
|---|---|
| Disko input and import | Keep. They provide declarative disk provisioning. |
| Default `networking.hostId` | Remove the shared default. Your `choshi` and `otaru` targets already provide distinct IDs. Correct the hostname comment. |
| ZFS boot support | Keep, including `forceImportRoot = false`. |
| Default `/dev/sda` | Set the actual device per host, preferably using `/dev/disk/by-id/...`. |
| 10 MiB BIOS boot partition | Remove only if the host is definitely UEFI-only. Keep if legacy BIOS/GRUB compatibility is needed. |
| EFI partition | Keep for UEFI. Your existing 4 GiB size is fine; shrinking it is not necessary for simplicity. |
| `ashift = "12"` | Keep. This is an important creation-time setting, not decorative tuning. |
| `autotrim = "on"` | Keep for SSD-backed storage; unnecessary for most HDDs. |
| Compression, `xattr`, ACL settings | Keep. A few useful defaults are worth retaining. |
| All `com.sun:auto-snapshot` properties | Remove until you actually configure a snapshot tool that uses them. |
| Separate `/nix`, `/home`, `/persist` datasets | Remove for the simplest layout. These directories can live on the root dataset. |
| Reserved-space dataset | Optional rather than essential. I would omit it for strict minimalism, but it is a useful safeguard against filling the pool. |

**Simplified Dataset Block**
Your entire `datasets` block could become:

```nix
datasets.root = {
  type = "zfs_fs";
  options.mountpoint = "legacy";
  mountpoint = "/";
};
```

And the inherited defaults could stay small:

```nix
rootFsOptions = {
  mountpoint = "none";
  compression = "zstd";
  xattr = "sa";
  acltype = "posixacl";
};
```

That gives you:

```text
Disk
├── EFI partition      /boot
└── ZFS partition
    └── zroot
        └── root       /
```

Add the BIOS boot partition only where needed. Bootloader configuration remains separate.

**One Practical Compromise**
For your configuration, I would consider keeping **two datasets: `/` and `/nix`**. That is slightly less minimal, but it lets future root snapshots exclude the large, frequently changing Nix store. I would not add `/persist` until you actually implement root rollback or impermanence.

No files changed; boot mode and the complete bootloader setup have not been verified. This is a fresh-install recommendation, not a migration procedure: removing dataset declarations does not move existing data, and rerunning Disko formatting can destroy it.

---

## User

Next would there be anything you would add that is considered best practice? Provided source for each change

---

## Assistant

I’ll check the NixOS and OpenZFS documentation for recommendations worth adding without making the setup unnecessarily complex.

**Tool: webfetch**

**Tool: webfetch**

**Tool: webfetch**

---

## Assistant

**Tool: webfetch**

**Tool: webfetch**

**Tool: webfetch**

---

## Assistant

For a minimal but well-maintained install, I would add **scheduled scrubs, disk-health monitoring, and backups**. Snapshots are useful too, but I would keep their policy small and explicit rather than introduce a larger management stack.

These are operational safeguards, not performance tuning.

### 1. Enable Monthly Scrubs
This is the first addition I would make:

```nix
services.zfs.autoScrub.enable = true;
```

NixOS defaults to a monthly schedule and scrubs all pools, so you do not need to specify either.

A scrub reads allocated data and verifies checksums, detecting corruption in files you might otherwise rarely access. With redundancy, ZFS can repair damaged blocks from another copy. On your single-disk pool, scrubbing still detects errors, but generally cannot repair damaged user data.

**Sources:** [OpenZFS `zpool-scrub(8)`](https://openzfs.github.io/openzfs-docs/man/master/8/zpool-scrub.8.html), [NixOS ZFS module, `services.zfs.autoScrub`](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/tasks/filesystems/zfs.nix).

### 2. Monitor Physical Disk Health
On bare metal:

```nix
services.smartd.enable = true;
```

NixOS enables device autodetection by default. SMART monitoring complements scrubbing: it watches drive-reported health indicators, whereas scrubbing verifies stored data.

For a VM, enable this on the physical host instead unless the guest actually has access to the drive's SMART interface.

**Important:** configure a notification channel you will notice. Default terminal notifications are insufficient for an unattended server.

**Source:** [NixOS smartd module](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/monitoring/smartd.nix), including autodetection, monitoring defaults, and notification options.

### 3. Deliver ZFS Error Notifications
NixOS already starts the ZFS Event Daemon, **ZED**, when ZFS support is enabled. You do not need another daemon-enabling option; you need a working notification destination.

For example, **if a sendmail-compatible mail service is already configured**:

```nix
services.zfs.zed = {
  enableMail = true;
  settings.ZED_EMAIL_ADDR = [ "you@example.com" ];
};
```

Setting an email address alone does not configure outgoing mail. I would connect this to whatever mail or monitoring infrastructure you already use, then test delivery.

**Sources:** [OpenZFS `zed(8)`](https://openzfs.github.io/openzfs-docs/man/master/8/zed.8.html), [NixOS ZFS module, ZED configuration and service startup](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/tasks/filesystems/zfs.nix).

### 4. Add A Small Snapshot Policy
If you want protection against accidental deletion, NixOS's built-in snapshot service is enough to start:

```nix
services.zfs.autoSnapshot = {
  enable = true;
  flags = "-k -p --utc";
  frequent = 0;
  hourly = 24;
  daily = 7;
  weekly = 4;
  monthly = 0;
};
```

Then opt in the dataset you want protected. Using the simplified layout from my previous answer:

```nix
disko.devices.zpool.zroot.datasets.root.options
  ."com.sun:auto-snapshot" = "true";
```

The retention counts above are **my suggested starting policy**, not an official universal recommendation. `--utc` follows the NixOS option documentation's advice to avoid timestamp problems around timezone and daylight-saving changes.

With a single root dataset, snapshots also retain old `/nix` contents. That is a concrete reason to keep `/nix` separate and excluded if snapshot space becomes significant.

**Snapshots retain deleted or changed blocks**, so monitor pool capacity. They do not protect against loss of the disk.

**Source:** [NixOS ZFS module, `services.zfs.autoSnapshot`](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/tasks/filesystems/zfs.nix), documenting opt-in properties, retention options, and UTC flags.

### 5. Back Up Outside This Pool
For important data, I would prioritize this over snapshots or extra dataset tuning.

Use a separate machine or independent storage destination. Native ZFS replication supports full and incremental snapshot transfers through `zfs send` and `zfs receive`; a file-based backup tool is also valid and does not require ZFS at the destination.

I would choose the tool only after choosing the destination and deciding which data needs recovery. Include a restore test, not just successful backup-job logs.

**Source:** [OpenZFS `zfs-send(8)`](https://openzfs.github.io/openzfs-docs/man/master/8/zfs-send.8.html), including backup streams, incremental transfers, and remote replication examples.

### 6. Consider A Mirror If Uptime Matters
This is a hardware-dependent recommendation, not something I would require for every personal installation.

A two-disk mirror provides a surviving copy after one disk fails and allows ZFS to repair corruption using the other copy. It does **not** replace backups, and booting after either disk fails also requires an appropriate boot-partition and bootloader setup.

**Source:** [OpenZFS `zpoolconcepts(7)`, “Virtual Devices” and “Device Failure and Recovery”](https://openzfs.github.io/openzfs-docs/man/master/7/zpoolconcepts.7.html). OpenZFS explicitly discourages non-redundant configurations because corruption can make data unavailable.

**My Minimal Recommendation**
Start with:

```nix
services.zfs.autoScrub.enable = true;
services.smartd.enable = true; # Physical hosts with accessible SMART data.
```

Then configure working alerts and external backups. Add automatic snapshots if you want local file-history recovery.

One correction to my earlier advice: current NixOS also enables **weekly periodic ZFS TRIM by default**, so `autotrim = "on"` is not necessary just to obtain TRIM support. There is no need to add another TRIM timer. [Source: NixOS ZFS module, `services.zfs.trim`](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/tasks/filesystems/zfs.nix).

No files changed. Sources were checked against current upstream documentation and `nixos-unstable`, not your pinned Nixpkgs revision; hardware support and notification delivery still need verification.

---

## User

For accidental deletion protection
can I set it up after my initial installaiton?

---

## Assistant

Yes. **You can enable automatic ZFS snapshots after installation**, without reinstalling, repartitioning, or formatting anything.

You would:
1. Enable `services.zfs.autoSnapshot` and choose retention settings.
2. Set `com.sun:auto-snapshot=true` on the existing datasets you want protected.
3. Rebuild your NixOS configuration.

**One Disko caveat:** do not assume changing a dataset property in the Disko layout will update an already-created dataset during `nixos-rebuild`. You can apply the property to the live dataset using `zfs set`, and keep the Disko declaration consistent for future installations. Do not rerun Disko formatting.

Protection begins only once a snapshot exists. Files deleted before your first snapshot cannot be recovered through this mechanism, and files created and deleted between snapshots are not captured.

No changes made. Snapshots protect against accidental deletion, not disk failure; keep independent backups for important data.

---

