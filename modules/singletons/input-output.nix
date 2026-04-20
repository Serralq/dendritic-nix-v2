{ ... }:
{
  den.aspects.input-output =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          # ** Printing
          services.printing.enable = true;

          # ** Pulse audio
          services.pulseaudio.enable = false;
          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };

          # ** Hardware graphics
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
            extraPackages = with pkgs; [
              vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
            ];
          };
          hardware.enableRedistributableFirmware = true;

          # ** Enable custom keyboards (voyager)
          services.udev.extraRules = ''
            # Rules for Oryx web flashing and live training
            KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
            KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

            # Legacy rules for live training over webusb (Not needed for firmware v21+)
              # Rule for all ZSA keyboards
              SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
              # Rule for the Moonlander
              SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
              # Rule for the Ergodox EZ
              SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
              # Rule for the Planck EZ
              SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

            # Wally Flashing rules for the Ergodox EZ
            ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
            ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
            SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
            KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

            # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
            SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
            # Keymapp Flashing rules for the Voyager
            SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
          '';
        };

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            pulseaudio # Adding the command line utils
            bluetuith # use nmtui for wifi, use gnome for captive portals
            # Connecting to keyboards
            # 1) Connect to GNOME's blt interface
            # 2) Hold f10 w/o fn key, keyboard will appear on the interface
            # 3) Reattach to computer body to use trackpad to select the keyboard
            # 4) Hold f10 again to actually accept the request
          ];
        };
    };
}
