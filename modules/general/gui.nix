{
  pkgs,
  den,
  lib,
  ...
}:

{
  flake-file.inputs = {
    winapps.url = "github:Insomniac66/winapps-nixos-fix";
  };

  den.aspects.required-gui = { config, ... }: {
    includes = [
      den.aspects.communication
      den.aspects.video
      den.aspects.photo
      den.aspects.editors
      den.aspects.terminal
      den.aspects.printing-3d
      den.aspects.office
      den.aspects.remote
      den.aspects.reading
    ];

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        bitwarden-desktop # Passwords
        popsicle # Formatting usb
        mission-center # Resource monitor
        todoist-electron # Notes app
        pavucontrol # GUI to check volume
        pika-backup # Just to get something
      ];
    };
  };
}
