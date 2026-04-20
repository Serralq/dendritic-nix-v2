{ ... }:
{
  den.aspects.video =
    { ... }:
    {
      nixos =
        { config, pkgs, ... }:
        {
          # For screen recording
          programs.obs-studio = {
            enable = true;
            enableVirtualCamera = true;

            plugins = with pkgs.obs-studio-plugins; [
              wlrobs
              obs-backgroundremoval
              obs-pipewire-audio-capture
              obs-gstreamer
              obs-vkcapture
            ];
          };
          boot.extraModulePackages = with config.boot.kernelPackages; [
            v4l2loopback
          ];
          boot.kernelModules = [ "v4l2loopback" ];
          boot.extraModprobeConfig = ''
            options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
          '';
        };

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            mpv # Video player
            shotcut # Video editing
            kdePackages.kdenlive # Better video editing
          ];
        };
    };
}
