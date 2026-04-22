{ ... }:
{
  den.aspects.file-management =
    { ... }:
    {
      flake-file.inputs = {
        copyparty.url = "github:9001/copyparty";
      };

      homeManager =
        { pkgs, config, ... }:
        {
          home.packages = with pkgs; [
            nautilus # GUI Backup file manager
            nemo # Better GUI manager
            qbittorrent # Torrenting files
            aria2 # Downloader faster
            megasync # Download from MEGA
            filezilla # ftp client
            localsend # Share files
            wget # Download
            curl # Download
            yt-dlp # Download / stream video
            dust # Disk usage
            baobab # Checking disk usage GUI
            fsearch # Index and search faster
            rarcrack # To crack rar passwords
            unrar # To open multi-part rar files
            unar # unrar but also allow for zips
            p7zip # Create zips of multiple parts with file limit
            unzip # Unzips
            # Eg: 7z a -v9m archive_name.7z /path/to/files
            trash-cli # For yazi undo button
            rclone # For the remote disk mounts
          ];

          services.syncthing.enable = true;

          systemd.user.services.copyparty-user = {
            Unit.After = [ "hyprland-session.target" ];
            Install.WantedBy = [ "hyprland-session.target" ];
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.copyparty}/bin/copyparty -c ${config.home.homeDirectory}/.config/copyparty/copyparty.conf";
              Restart = "on-failure";
            };
          };

          systemd.user.services.rclone-mount = {
            Unit.After = [ "hyprland-session.target" ];
            Install.WantedBy = [ "hyprland-session.target" ];
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.rclone}/bin/rclone mount --vfs-cache-mode writes --dir-cache-time 5s nixos-dav: ${config.home.homeDirectory}/Remote-Disk/";
              Restart = "on-failure";
            };
          };
        };
    };
}
