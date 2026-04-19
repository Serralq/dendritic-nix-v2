# * Header
{
  pkgs,
  inputs,
  lib,
  ...
}:

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
    hermit # Font
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.iosevka
    symbola
    notonoto
    julia-mono
    kdePackages.fcitx5-configtool # Setting up Jp IME
    libnotify # To test notification
    pulseaudio # Adding the command line utils

    # ** Hyprland / DE / Keyboard-shortcuts
    cliphist # Clipboard manager
    wl-clipboard
    ydotool
    grimblast # Better screenshots
    brightnessctl # For brightness cmd
    waybar # TODO create a currently listening
    mpvpaper
    socat # Control forked mpvpaper
    playerctl # Allow to check what's currently playing
    hyprcursor # TODO Util to convert Xcursor to hyprcursor
    xcur2png # Help extract xcursor
    # TODO LWP Settup in the future
    pmutils # Check battery -> Change border colors
    nwg-look # Affects the mouse cursor in a different way
    kitty # For hyprland fallback
    waypaper # Basic wallpaper GUI
    swayidle # Dim wallpaper when idle
    wtype # Allow to send keymaps
    # TODO Learn to package a app launcher that has premade plugins (vicinae)
    # TODO Auto pause background music when detect another audio is playing
    # Waybar already has rust plugin that can detect what's currently playing
    # TODO https://www.wfdownloader.xyz/download to mass download twitter posts
    hyprpicker # Get colors from screen
    wev # Figure out what output from input devices
    hypridle # For locking the computer

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

    # ** Gaming
    protonup-ng # Improve proton
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamemode
        pkgs.gamescope
      ];
    })

    # ** Office suit
    hunspell
    libreoffice-qt
    hunspellDicts.en_US-large

  ];

  # * Services
  # ** Syncthing
  services.syncthing.enable = true;

  # ** Notifications: Dunst
  # Notification daemon, search "notify-send" to find
  # Only if requires immediate action
  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      offset = "(8, 8)";
      origin = "top-right";
      frame_width = "2";
      font = "Hermit";
      follow = "mouse";
      background = "#2e3440";
      width = "(80,300)";
    };
    urgency_normal = {
      frame_color = "#a3be8c";
      foreground = "#a3be8c";
      # Just long enough for me to notice
      timeout = "2";
    };
    urgency_low = {
      foreground = "#5e81ac";
      frame_color = "#5e81ac";
      timeout = "2";
    };
    urgency_critical = {
      foreground = "#bf616a";
      frame_color = "#bf616a";
      timeout = "30";
    };
  };

  # ** Hyprlock
  programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
    general = {
      hide_cursor = true;
      ignore_empty_input = true;
      fail_timeout = 1000; # Just long enough to feel this
    };
    background = {
      # Type of background
      path = "screenshot";
      monitor = "";
      # Background settings
      blur_passes = 1;
      blur_size = 6;
      brightness = 0.7;
      noise = 0;
    };
    input-field = {
      # Size
      size = "500, 150"; # Height controls font size, 440 keeps it balanced
      outline_thickness = 6;
      # Position
      monitor = "";
      halign = "center";
      valign = "center";
      # Shape
      rounding = 0;
      # Behavior
      hide_input = true;
      fade_on_empty = false;
      # Text
      font_family = "Hermit";
      placeholder_text = "<i>最高性ですから</i>";
      fail_text = "ダメ";
      # Colors
      font_color = "rgba(216, 222, 233, 1)";
      inner_color = "rgba(0,0,0,0.0)";
      outer_color = "rgba(46, 52, 64, 1) rgba(76, 86, 106, 1) 90deg";
      fail_color = "rgba(191, 97, 106, 1) rgba(208, 135, 112, 1) 90deg";
      check_color = "rgba(94, 129, 172, 1) rgba(136, 192, 208, 1) 90deg";
    };
    animations = {
      animation = [
        # Disabled animations
        "fadeOut, 0, 1" # Disable else delays the notification popup
        "inputFieldWidth, 0, 10"
        "inputFieldDots, 0, 10"
        "inputFieldFade, 0, 10"
        # Enabled animation
        "inputFieldColors, 1, 50"
        # (transitions for the entire length that blue / red appears)
        # (multiple of the actual animation so it doesn't complete before next transition)
        "fadeIn, 1, 10" # (within fastest time to type password)
      ];
    };
  };

  # ** TODO HyprIdle, to have mute
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        on_unlock_cmd = lib.concatStringsSep " " [
          "/home/serralq/.scripts/border-color.sh --all &"
          "pactl set-sink-volume @DEFAULT_SINK@ 0% &"
        ];
      };
    };
  };

  # ** Direnv
  programs = {
    direnv = {
      enable = true;
      enableFishIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
  };

  # * Hyprland
  # Window manager, use of hyrplandPlugins... to get plugins
  # Last updated: March 8, ver 0.52.0 (v53 is broken, v54 doesn't have plugin support yet)
  # TODO Split this into it's own space
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemd.enable = true;
    systemd.variables = [ "--all" ];
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    plugins = [
      inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
      inputs.hy3.packages.${pkgs.system}.hy3
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    ];

    # ** General Settings
    settings = {
      permission = "/usr/(bin|local/bin)/hyprpm, plugin, allow";

      env = [
        "GTK_THEME,Adwaita:dark"
      ];

      monitor = [
        "eDP-1,2880x1800@60,0x0,1.8, bitdepth, 10, cm, hdr"
        "eDP-2,2880x1800@60,0x1000,1.8, bitdepth, 10, cm, hdr" # Bottom monitor
        ",preferred,auto,1" # For auto external monitors
      ];

      general = {
        gaps_in = "4";
        gaps_out = "8";
        border_size = "2";
        "col.inactive_border" = "rgba(595959aa)";
        allow_tearing = "true";
        layout = "hy3";
        resize_on_border = "true";
        extend_border_grab_area = "30";
      };

      group = {
        groupbar = {
          # TODO add font weight, turn off when not in focus, gradients into hy3
          # Or into native, borders
          # Native tabstack vs plugin tab stacks
          # Both missing: allow for tabs on the bottom
          # Allow for app name first
        };
      };

      decoration = {
        dim_inactive = "true";
        dim_strength = "0.11";

        shadow = {
          enabled = "false"; # Battery hogs
          range = "8";
          render_power = "2";
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = "false";
          size = "5";
          passes = "2";
        };
      };

      animations = {
        workspace_wraparound = "true";

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
          "overshoot, 0.05, 0.9, 0.1, 1.1"
        ];

        animation = [
          "global, 1, 10, default"
          "windows, 1, 2.75, easeOutQuint, slide"
          "fade, 1, 1.8, almostLinear"
          "border, 1, 5.50, easeOutQuint"
          "workspaces, 1, 2.00, easeOutQuint, slide"

          # Disabled
          "windowsMove, 0, 1.49, linear, popin 87%"
          "layers, 0, 3.81, easeOutQuint"
        ];
      };

      dwindle = {
        pseudotile = "true";
        preserve_split = "true";
      };

      master = {
        new_status = "master";
      };

      #windowrule = [
      #  # "no_focus on, match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pinned false"
      #  "float on, match:title ^(Picture in picture)$"
      #  "pin on, match:title ^(Picture in picture)$"
      #  "size 200 200, match:title ^(Picture in picture)$"
      #  "move 1348 790, match:title ^(Picture in picture)$"
      #];

      windowrulev2 = [
        "float, title:^(Picture in picture)$"
        "pin, title:^(Picture in picture)$"
        "size 200 200, title:^(Picture in picture)$"
        "move 1348 790, title:^(Picture in picture)$"
      ];

      exec-once = [
        "~/.config/hypr/startup.sh &"
        "hypridle"
      ];

      # ** Bindings
      input = {
        kb_options = "caps:escape, ctrl:swap_lalt_lctl";
        # Testing this out
        sensitivity = "1"; # Clamped to 1
        accel_profile = "flat";
        repeat_delay = "180";
        repeat_rate = "50";
        # Allow for click and drag scrolling
        # TODO Remove if not using the trackball
        scroll_method = "on_button_down";
        scroll_button = "275";
        scroll_factor = "0.3";

        touchpad = {
          natural_scroll = "true";
          disable_while_typing = "true";
        };

        # To prevent broken screen from creating inputs
        touchdevice = {
          enabled = "false";
        };
      };

      cursor = {
        hide_on_key_press = "true";
      };

      misc = {
        enable_swallow = true;
        swallow_regex = "(org.wezfurlong.wezterm)";
        vfr = "true";
      };

      "$mainMod" = "SUPER";

      binde = [
        "bind = SUPER, H, exec, wtype -k Left"
        "bind = SUPER, J, exec, wtype -k Down"
        "bind = SUPER, K, exec, wtype -k Up"
        "bind = SUPER, L, exec, wtype -k Right"
      ];

      bindl = [
        "$mainMod, SPACE, exec, wezterm"
        "ALT, SPACE, exec, grimblast copy area" # Screenshots
        # TODO For monitor screen keybindings, don't forget to update debug msg
        # One screen to svae power, two screen to use power
        "$mainMod, B, exec, ~/stow/.config/hypr/battery-saver.sh & "
        "$mainMod SHIFT, B, exec, ~/stow/.config/hypr/second-monitor.sh &"
        # Just adding the commands would fail for some reason to execute the second mpvpaper command
        # Start the bottom monitor and start the wallpaper
        "$mainMod, C, exec, emacsclient -c --eval '(thanos/type)'"
        "$mainMod, V, exec, ~/.config/hypr/workspace-manager.sh --swap-monitors"
        "$mainMod, N, exec, ~/.config/hypr/workspace-manager.sh --debug"
        "$mainMod, W, killactive,"
        "$mainMod, M, exit,"
        # Allow for the initial sleep
        "$mainMod, comma, exec, hyprlock"
        "$mainMod, period, hyprexpo:expo, toggle"
        "$mainMod, slash, exec, ~/.config/hypr/workspace-manager.sh --debug"

        "$mainMod, D, hy3:changegroup, toggletab"
        "$mainMod SHIFT, D, hy3:makegroup, tab, toggle"
        "$mainMod, F, hy3:focustab, r, wrap"
        "$mainMod, S, hy3:focustab, l, wrap"

        # "$mainMod, H, hy3:movefocus, l"
        # "$mainMod, L, hy3:movefocus, r"
        # "$mainMod, K, hy3:movefocus, u"
        # "$mainMod, J, hy3:movefocus, d"

        "$mainMod SHIFT, H, hy3:movewindow, l"
        "$mainMod SHIFT, L, hy3:movewindow, r"
        "$mainMod SHIFT, K, hy3:movewindow, u"
        "$mainMod SHIFT, J, hy3:movewindow, d"

        # TODO Create script for multimonitor support
        # TODO Add rename options to terminal
        # If both on monitor don't change,
        # If either not in monitor
        # Navigation (1-5) within current group
        "$mainMod, 1, exec, ~/.config/hypr/workspace-manager.sh --switch 1"
        "$mainMod, 2, exec, ~/.config/hypr/workspace-manager.sh --switch 2"
        "$mainMod, 3, exec, ~/.config/hypr/workspace-manager.sh --switch 3"
        "$mainMod, 4, exec, ~/.config/hypr/workspace-manager.sh --switch 4"
        "$mainMod, 5, exec, ~/.config/hypr/workspace-manager.sh --switch 5"

        # Group Selection (Mod + Shift + 1-5)
        "$mainMod SHIFT, 1, exec, ~/.config/hypr/workspace-manager.sh --set-group 0"
        "$mainMod SHIFT, 2, exec, ~/.config/hypr/workspace-manager.sh --set-group 1"
        "$mainMod SHIFT, 3, exec, ~/.config/hypr/workspace-manager.sh --set-group 2"
        "$mainMod SHIFT, 4, exec, ~/.config/hypr/workspace-manager.sh --set-group 3"
        "$mainMod SHIFT, 5, exec, ~/.config/hypr/workspace-manager.sh --set-group 4"

        # Move Window to Relative Workspace (Mod + Alt + 1-5)
        "$mainMod ALT, 1, exec, ~/.config/hypr/workspace-manager.sh --move-window 1"
        "$mainMod ALT, 2, exec, ~/.config/hypr/workspace-manager.sh --move-window 2"
        "$mainMod ALT, 3, exec, ~/.config/hypr/workspace-manager.sh --move-window 3"
        "$mainMod ALT, 4, exec, ~/.config/hypr/workspace-manager.sh --move-window 4"
        "$mainMod ALT, 5, exec, ~/.config/hypr/workspace-manager.sh --move-window 5"

        # Move Active Window to same slot in a different Group (Mod + Alt + Shift + 1-5)
        "$mainMod ALT SHIFT, 1, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 0"
        "$mainMod ALT SHIFT, 2, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 1"
        "$mainMod ALT SHIFT, 3, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 2"
        "$mainMod ALT SHIFT, 4, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 3"
        "$mainMod ALT SHIFT, 5, exec, ~/.config/hypr/workspace-manager.sh --move-to-group 4"

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        ", F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\" & "
        ", F3, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ & wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; dunstify -u low -r 9910 \"Volume: $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')\" & "
        ", F5, exec, brightnessctl s 10%- & brightnessctl -d intel_backlight s 10%-"
        ", F6, exec, brightnessctl s 10%+ & brightnessctl -d intel_backlight s 10%+"

        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"

        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"

        # TODO Doesn't work since left is sent along with the ctrl
        # "CTRL, H, exec, wtype -k Left"
        # "CTRL, J, exec, wtype -k Down"
        # "CTRL, K, exec, wtype -k Up"
        # "CTRL, L, exec, wtype -k Right"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # ** Plugins
      plugin = {
        dynamic-cursors = {
          enabled = "true";
          mode = "tilt";

          tilt = {
            function = "quadratic";
            window = "100";
            limit = "1500";
          };

          shake = {
            enabled = "false";
          };
        };

        hyprtrails = {
          color = "rgba(88C0D0FF)";
        };

        hyprexpo = {
          columns = "5";
          gap_size = "0";
          bg_col = "rgb(000000)";
          workspace_method = "center current";
        };

        hy3 = {
          tab_first_window = "true";
          tabs = {
            text_font = "Hermit";
            text_height = "10";
            border_width = "4";
            "col.inactive" = "rgba(595959DD)";
            "col.inactive.border" = "rgba(2E3440FF)";
            "col.active" = "rgba(5E81ACFF)";
            "col.active.border" = "rgba(2E3440FF)";
          };
        };
      };
    };
  };
}
