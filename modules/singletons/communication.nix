{ ... }:

{
  den.aspects.communication = { ... }: {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        discord # Online chat
        webcord # Discord but wayland
        slack # Work / School communications
        zoom-us # School meetings
      ];
    };
  };
}
