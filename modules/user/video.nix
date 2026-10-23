{ ... }:
{
  den.aspects.video = {
    nixos =
      { config, pkgs, ... }:
      {

        # For screen recording
        # Confirmed has to be in the nixos class
        programs.obs-studio = {
          enable = true;
          enableVirtualCamera = false;

          plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-backgroundremoval
            obs-pipewire-audio-capture
            obs-gstreamer
            obs-vkcapture
          ];
        };

        boot.kernelModules = [ "v4l2loopback" ];

        boot.extraModulePackages = [
          config.boot.kernelPackages.v4l2loopback
        ];

        boot.extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=10 card_label="Loopback Camera" exclusive_caps=1
        '';

        users.users.serralq.extraGroups = [ "video" ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          mpv # Video player
          vlc # Backup video player
          shotcut # Video editing
          kdePackages.kdenlive # Better video editing
          ffmpeg # to allow for video looping and conversions
          v4l-utils # for the virtual camera
        ];
      };
  };
}
