{
  description = "Main Config";

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config.flake;

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-heavy.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.52.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.52.0";
      inputs.hyprland.follows = "hyprland";
    };

    hy3 = {
      url = "github:outfoxxed/hy3/hl0.52.0";
      inputs.hyprland.follows = "hyprland";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors/8c1679b87c54e97145cae83e622956d720e88bef";
      inputs.hyprland.follows = "hyprland";
    };

    affinity-nix.url = "github:mrshmllow/affinity-nix";
    copyparty.url = "github:9001/copyparty";
    parsecgaming.url = "github:DarthPJB/parsec-gaming-nix";
    winapps.url = "github:Insomniac66/winapps-nixos-fix";
    nix-alien.url = "github:thiagokokada/nix-alien";
    tagstudio.url = "github:TagStudioDev/TagStudio";
    sops-nix.url = "github:Mic92/sops-nix";
    t3code.url = "github:rodeyseijkens/t3code-nix";
    devenv.url = "github:cachix/devenv";

    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";
  };
}
