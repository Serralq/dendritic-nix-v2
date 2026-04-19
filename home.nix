# * Header
{ pkgs, inputs, ... }:

let
  bambu-appimage = import ./modules/_nixos/bambu-appimage.nix { inherit pkgs; };
in
{

  # * System Configs
  home.username = "serralq";
  home.homeDirectory = "/home/serralq";
  home.stateVersion = "25.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  # Allow for zed acceleration
  targets.genericLinux.nixGL.vulkan.enable = true;

  # * System Packages
  home.packages = with pkgs; [
    libnotify # To test notification
    pulseaudio # Adding the command line utils

    # * Terminal
    wget # Download
    curl # Download
    jq # Parse stdout
    ripgrep # Greps but faster, written in Rust
    unzip # Unzips
    openvpn # VPN use
    docker # Docker container
    lazydocker # Easier version of docker
    btop # Resource monitor
    fzf # Fuzzy finder
    dust # Disk usage
    fd # A better find
    eza # Better ls
    wordnet # For offline emacs dictionary
    ispell # For emacs to stop giving errors
    imagemagick # Edit image properties in the terminal
    xeyes # Checking if using xwayland
    yt-dlp # Download / stream video
    ffmpeg # All media convertions
    jc # JSON parser for stdout
    jq # JSON parser for stdout
    pandoc # document convertions
    mediainfo # Allow for more media preview in yazi
    trash-cli # For yazi undo button
    mokuro # To read jp manga
    # Requires pdf to png
    # May require a delete and reinstall
    # Don't touch after it starts running
    # On intel gpu will take literal days for a book
    bluetuith # use nmtui for wifi, use gnome for captive portals
    # Connecting to keyboards
    # 1) Connect to GNOME's blt interface
    # 2) Hold f10 w/o fn key, keyboard will appear on the interface
    # 3) Reattach to computer body to use trackpad to select the keyboard
    # 4) Hold f10 again to actually accept the request
    cloudflared # Allow for external links
    sqlite # Sqlite
    appimage-run # To run app images
    rarcrack # To crack rar passwords
    unrar # To open multi-part rar files
    unar # unrar but also allow for zips
    p7zip # Create zips of multiple parts with file limit
    # Eg: 7z a -v9m archive_name.7z /path/to/files
    wl-clipboard-x11 # To access clipboard from terminal
    rclone # For file transfers
    sops # To decrypt sops secrets
    bat # Better cat
    su-exec # Allow for switching user and then execute
    # Man pages
    man
    man-pages
    man-pages-posix
    vips # For emacs dirvish
    ueberzugpp # For yazi image preview
    xdg-desktop-portal-termfilechooser # Yazi as file chooser
    texliveSmall

    # * DevOps
    neovim # Basic editor
    zed-editor # Trying new one
    fish # Terminal prompt
    starship # Terminal prompt look
    fastfetch # Terminal splash screen
    yazi # File manager
    zoxide # Quick jump
    atuin # Terminal History
    pay-respects # Fixing previous terminal command
    fishPlugins.fifc # Fish auto completion fzf
    nushell # When I need structured contents
    carapace # Better terminal autocomplete
    # Ai in terminal, each have different harness that they were trained on and optimized for
    claude-code
    gemini-cli
    codex
    opencode
    codeium # Ai autocomplete
    inputs.t3code.packages.${pkgs.system}.default # For t3code better threads
    sshfs # For working over ssh eg yazi

    # ** Nix Packages
    devenv # Allows for custom env (inclu nightly rust)
    nix-tree # See size of nix
    nh # Better nix commands (rebuild, clean)
    nix-search-tv # Interactive search
    nix-your-shell # So nix develop goes into fish
    nix-index # To find missing binaries
    deadnix # Better nix config
    inputs.nix-alien.packages.${pkgs.system}.nix-alien # Running binaries in nix

    # ** Other Languages
    # Rust
    rustc
    jetbrains.rust-rover
    cargo
    # Go
    jetbrains.goland
    go
    # Java
    jetbrains.idea # For 25.11
    jre25_minimal
    # Python
    (python-latest.withPackages (
      ps: with ps; [
        # To serve my website
        mkdocs-material
        mkdocs-glightbox
        mkdocs-autolinks-plugin
        cairosvg
        pillow
      ]
    ))
    jetbrains.pycharm
    # Javascript
    nodejs_24 # For javascript deployments
    yarn # Js package manager
    # c/c++
    jetbrains.clion # For c/c++
    libgcc # For compiling c/c++, use the below to start gcc
    # gcc # Also for gcc # Only use with direnv
    cmake-language-server
    gdb # c/c++ debugger
    # ida-free # Binary dissassmebly
    # Requires a pre install into the nix store
    valgrind # Chcek for memory leaks
    cmake # Compiling c programs
    gnumake # Getting the make command
    clang # Compiling c programs?
    libtool # To compile vterm
    zed-editor # Fast version of vs code

    # ** Git/JJ
    stow # Manage dot files
    git # Track files
    gh # Github specific commands
    git-filter-repo # Remove from history
    github-desktop # Way to check in a GUI
    difftastic # For better git syntax highlight
    lazygit # TUI for git file tree exploration
    jujutsu # Better git?
    jj-starship
    jjui # another jj tui

    # * GUI Packages
    anki # Jp study
    bitwarden-desktop # Passwords
    # TODO Fix important passwords
    discord # Online chat
    emacs-pgtk # Main note taking, may require a doom install, only ver supporting wayland
    localsend # Share files
    megasync # Download from MEGA
    popsicle # Formatting usb
    qbittorrent # Torrenting files
    aria2 # Downloader faster
    vscode # for VScode plugin's GUI
    wezterm # Terminal
    kitty # For testing + wayland
    mpv # Video player
    nautilus # GUI Backup file manager
    nemo # Better GUI manager
    pavucontrol # GUI to check volume
    webcord # Discord but wayland
    baobab # Checking disk usage GUI
    slack # Work / School communications
    zoom-us # School meetings
    foliate # Epub reader
    inputs.parsecgaming.packages.${pkgs.system}.parsecgaming # Remote desktop
    # Photography / Photo editing
    gimp3-with-plugins
    rawtherapee
    shotcut # Video editing
    kdePackages.kdenlive # Better video editing
    freerdp # Remote desktop directly into windows container
    tagstudio # TagStudio
    fsearch # Index and search faster
    # TODO Resource monitors
    mission-center
    # obs-studio # For screen recorder
    filezilla # ftp client
    freecad # For 3d printing
    orca-slicer # Also for 3d printing
    bambu-appimage # To send files to 3d printer w/ auth
    pika-backup # Just to get something
    todoist-electron # Notes app
    inputs.affinity-nix.packages.${pkgs.system}.v3 # Affinity image editors

    # ** Office suit
    hunspell
    libreoffice-qt
    hunspellDicts.en_US-large

  ];

  # * Services
  # ** Syncthing
  services.syncthing.enable = true;

  # ** Direnv
  programs = {
    direnv = {
      enable = true;
      enableFishIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  };

}
