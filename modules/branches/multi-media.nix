{ den, ... }:

{
  flake-file.inputs = {
    winapps.url = "github:Insomniac66/winapps-nixos-fix";
  };

  den.aspects.multi-media = { ... }: {
    includes = [
      den.aspects.video
      den.aspects.photo
      den.aspects.printing-3d
      den.aspects.office
      den.aspects.remote
      den.aspects.reading
      den.aspects.converter
    ];

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        # TODO Fix important passwords
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
