# How nh os switch resolves and activates hirakata

**Session ID:** ses_ea5a278b4ffesEbzd9cAqO1hSy
**Created:** 10/20/2026, 1:30:41 PM
**Updated:** 10/20/2026, 1:35:54 PM

---

## User

Based on my current nixos configuation can you explain how nh os switch .#hirakata --cores 16 finds its target and then executes on this target?

---

## Assistant

I’ll trace how your flake selects `hirakata`, then check how `nh` builds and activates it, including what `--cores 16` controls.


**Tool: read**

**Tool: bash**

**Tool: task**

---

## Assistant

**Tool: bash**

**Tool: bash**

**Tool: read**

**Tool: read**

**Tool: read**

---

## Assistant

**Tool: webfetch**

---

## Assistant

**Tool: webfetch**

---

## Assistant

**Tool: webfetch**

**Tool: read**

**Tool: read**

**Tool: read**

---

## Assistant

**Tool: webfetch**

---

## Assistant

**Tool: webfetch**

---

## Assistant

**Tool: webfetch**

---

## Assistant

**Tool: webfetch**

---

## Assistant

`nh os switch .#hirakata --cores 16` means:

> Build the `hirakata` NixOS configuration exported by the flake in the current directory, then activate it **on the machine running the command** and make it the boot default.

The important distinction is that **`hirakata` selects a configuration, not a remote machine**.

## 1. How It Finds `hirakata`

Your installed version is `nh 4.4.1`. It interprets the command as:

| Part | Meaning |
|---|---|
| `nh os` | Manage a NixOS system |
| `switch` | Activate now and make the configuration the boot default |
| `.` | Use the flake in your current directory |
| `#hirakata` | Select the NixOS configuration named `hirakata` |
| `--cores 16` | Pass a build parallelism setting to Nix |

For this command, `nh` expands the abbreviated selector into:

```nix
nixosConfigurations.hirakata.config.system.build.toplevel
```

So the build is conceptually:

```bash
nix build \
  .#nixosConfigurations.hirakata.config.system.build.toplevel \
  --cores 16 \
  --out-link <temporary-result-path>
```

`nh` also provides build monitoring and a configuration diff around this operation.

Because you explicitly supplied `#hirakata`, the local hostname is not needed to choose the configuration. Without a selector, as in `nh os switch .`, `nh` normally uses the local hostname.

## 2. Where Your Flake Exports It

You do not explicitly write `nixosConfigurations.hirakata = ...`. **Den generates that output from your host declaration.**

Your entry point is [`flake.nix:4`](flake.nix#L4):

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake
    { inherit inputs; }
    (inputs.import-tree ./modules);
```

This imports your modules as flake-parts modules. [`modules/dendritic.nix:3-6`](modules/dendritic.nix#L3) brings in Den’s dendritic integration.

The actual host declaration is in [`modules/user/developer/nix/overlay.nix:70`](modules/user/developer/nix/overlay.nix#L70):

```nix
den.hosts.x86_64-linux.hirakata.users.serralq = { };
```

This tells Den:

- There is a host named `hirakata`.
- Its platform is `x86_64-linux`.
- It includes the user `serralq`.

Den associates those names with your named aspects:

```text
den.hosts.x86_64-linux.hirakata.users.serralq
    |
    +-- den.aspects.hirakata
    |     Host hardware, filesystems, bootloader, security, overlays
    |
    +-- den.aspects.serralq
          User definition, desktop, developer tools, networking, etc.
    |
    v
nixosConfigurations.hirakata
    |
    v
config.system.build.toplevel
```

The host aspect is defined in [`modules/targets/hirakata.nix:3-10`](modules/targets/hirakata.nix#L3). It includes:

```nix
den.provides.hostname
den.aspects.overlays
den.aspects.security
den.aspects.systemd-bootloader
den.aspects.admin-identity
```

The hostname provider derives the configured hostname from the host’s name. **That sets the hostname of the resulting system; it does not tell `nh` where to deploy.**

Your user aspect is defined in [`modules/targets/hirakata/serralq.nix:3-16`](modules/targets/hirakata/serralq.nix#L3). Den incorporates its NixOS and Home Manager configuration into the host.

Also, the directory name `targets/` is your organizational convention. `nh` does not scan it for targets; it only sees the resulting flake outputs.

## 3. What Gets Built

`config.system.build.toplevel` is the derivation representing the assembled NixOS system.

Building it produces a store path resembling:

```text
/nix/store/<hash>-nixos-system-hirakata-<version>
```

That system output references its required packages, kernel, configuration files, systemd units, activation tooling, and other dependencies.

Nix reuses existing store paths and downloads available substitutes. It only builds what is missing, rather than recompiling the entire system every time.

Your integrated Home Manager configuration is also part of this deployment, rather than requiring a separate `nh home switch`.

## 4. How It Activates

There is **no `--target-host` in your command**, so activation happens locally. Your inspected modules also contain no remote builder or deployment destination settings.

For your installed `nh 4.4.1`, the local `switch` sequence is more specifically:

1. Build the new system and display the applicable diff.
2. Validate that essential files exist in the built system.
3. Run the new system’s `bin/switch-to-configuration test` with elevated privileges. This activates the configuration for the running system, including activation scripts and service changes.
4. Update `/nix/var/nix/profiles/system` to the new system, recording the system generation.
5. Run the new system’s `bin/switch-to-configuration boot` with elevated privileges, updating the boot configuration.

Thus, this version of `nh` implements local `switch` as **runtime activation followed by profile and boot updates**, rather than simply invoking `switch-to-configuration switch` once.

Your host includes the systemd-boot configuration from [`modules/host/systemd-bootloader.nix:7-10`](modules/host/systemd-bootloader.nix#L7), so the boot update uses systemd-boot and your `/boot` EFI filesystem.

No automatic reboot occurs. Changes such as a new kernel take effect on the next boot.

## 5. What `--cores 16` Controls

`--cores 16` sets Nix’s **cores-per-build** setting. Builders that honor it can use it for parallel compilation, commonly through `NIX_BUILD_CORES`.

It does **not** mean:

- Build exactly 16 packages simultaneously.
- Limit all Nix processes together to 16 CPU threads.
- Run activation with 16 cores.
- Persist a 16-core setting in your NixOS configuration.

The separate `--max-jobs` option controls how many build jobs Nix can run concurrently. Multiple concurrent builds can each use the cores setting, so `--cores 16` alone is not a global CPU cap.

**Bottom line:** `.#hirakata` answers **“which system configuration?”**; the absence of `--target-host` answers **“apply it here.”** Running this command on another NixOS machine would attempt to apply your `hirakata` configuration there, including its host-specific filesystem and hardware settings.

---

## User

My more specific question is how does from import-tree discover dendritic.nix?

---

## Assistant

**Tool: webfetch**

---

## Assistant

**Tool: webfetch**

---

## Assistant

`import-tree` discovers `dendritic.nix` by **recursively scanning `./modules` for `.nix` files**. The name `dendritic.nix` has no special meaning to it.

### 1. Your Flake Starts The Scan

In [`flake.nix:4`](flake.nix#L4):

```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake
    { inherit inputs; }
    (inputs.import-tree ./modules);
```

The expression:

```nix
inputs.import-tree ./modules
```

creates a module whose `imports` list contains the discovered files. Conceptually, it produces:

```nix
{
  imports = [
    ./modules/dendritic.nix
    ./modules/targets/hirakata.nix
    ./modules/targets/hirakata/serralq.nix
    ./modules/user/developer.nix
    ./modules/user/developer/nix.nix
    # ...other discovered .nix files
  ];
}
```

By default, it selects `.nix` files and excludes paths containing `/_`, allowing files or directories prefixed with `_` to stay outside automatic imports.

### 2. The Module System Evaluates Each File

`mkFlake` passes that generated module into the Nix module system. The module system follows its `imports` and evaluates [`modules/dendritic.nix`](modules/dendritic.nix#L1):

```nix
{ inputs, ... }:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  # ...
}
```

`inputs` is available to this module because you passed `{ inherit inputs; }` to `mkFlake`.

The module system then follows **these additional imports**, loading the flake-file and Den integrations.

### 3. This Is Not Sequential Loading

It is not:

```text
Load dendritic.nix first
Then load host declarations
Then load aspects
```

Instead:

```text
import-tree scans ./modules
        |
        v
Creates an imports list of matching files
        |
        v
The module system collects those modules and their nested imports
        |
        v
Evaluates their combined option declarations and definitions
```

That is why another file can define `den.hosts...` even though the Den integration is imported from `dendritic.nix`: **the files participate in one combined module evaluation, rather than executing in filename order.**

You could rename `dendritic.nix` to `integrations.nix` and discovery would still work. Moving it to `_dendritic.nix` would exclude it from the default scan.

---

## User

What tells it to do dendritic.nix first?

---

## Assistant

**Nothing tells it to evaluate `dendritic.nix` first. It does not need to be first.**

Nix modules are not scripts executed top to bottom. The module system conceptually:

1. Collects all modules from `imports`, recursively.
2. Collects their option declarations, such as the `den` options provided by Den.
3. Merges and lazily evaluates the definitions supplied by all those modules.

For example, these can appear in either order:

```nix
# Module A: declares an option
{ lib, ... }: {
  options.example = lib.mkOption {
    type = lib.types.str;
  };
}
```

```nix
# Module B: sets that option
{
  example = "hello";
}
```

Module B does not require Module A to have already “run.” They contribute to the **same combined configuration**.

Your configuration works the same way:

| File | Contribution |
|---|---|
| `dendritic.nix` | Imports Den’s integration, which supplies the `den` configuration machinery |
| `overlay.nix` | Defines `den.hosts.x86_64-linux.hirakata...` |
| `hirakata.nix` | Defines `den.aspects.hirakata` |

`import-tree` discovers these files; the module system combines them. **The filename `dendritic.nix` gives it no priority.**

One nuance: the module system must discover imports before it can evaluate the complete configuration. That is why your `dendritic.nix` imports depend on the already-supplied `inputs`, not on a configuration value that those same imports would need to define.

---

