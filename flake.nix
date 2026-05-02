# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    copyparty.url = "github:9001/copyparty";
    den.url = "github:vic/den";
    devenv.url = "github:cachix/devenv";
    disko.url = "github:nix-community/disko";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    hy3 = {
      url = "github:outfoxxed/hy3/hl0.52.0";
      inputs.hyprland.follows = "hyprland";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors/8c1679b87c54e97145cae83e622956d720e88bef";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland.url = "github:hyprwm/Hyprland/v0.52.0";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.52.0";
      inputs.hyprland.follows = "hyprland";
    };
    import-tree.url = "github:vic/import-tree";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-value-json.url = "github:oldshensheep/nix-value-json";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-heavy.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    parsecgaming.url = "github:DarthPJB/parsec-gaming-nix";
    sem-cli.url = "github:Ataraxy-Labs/sem";
    sops-nix.url = "github:Mic92/sops-nix";
    t3code.url = "github:rodeyseijkens/t3code-nix";
    tagstudio.url = "github:TagStudioDev/TagStudio";
    winapps.url = "github:Insomniac66/winapps-nixos-fix";
  };
}
