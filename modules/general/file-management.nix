{ pkgs, lib, ... }:

{
  den.aspects.file-management = { config, ... }: {
    homeManager = { pkgs, ... }: {
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
      ];

      services.syncthing.enable = true;
    };
  };
}
