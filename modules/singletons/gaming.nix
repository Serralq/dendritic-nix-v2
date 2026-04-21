{ ... }:

{
  den.aspects.gaming = { ... }: {
    nixos = { pkgs, ... }: {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
        protontricks.enable = true;
      };
      programs.gamemode.enable = true;
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        protonup-ng # Improve proton
        (heroic.override {
          extraPkgs = pkgs: [
            pkgs.gamemode
            pkgs.gamescope
          ];
        })
      ];
    };
  };
}
