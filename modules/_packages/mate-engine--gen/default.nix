{
  alsa-lib,
  at-spi2-core,
  autoPatchelfHook,
  cairo,
  coreutils,
  cups,
  dbus,
  expat,
  fetchurl,
  fontconfig,
  freetype,
  gawk,
  gdk-pixbuf,
  glib,
  gnugrep,
  gtk3,
  jq,
  lib,
  libayatana-appindicator,
  libdrm,
  libGL,
  libpulseaudio,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXinerama,
  libxkbcommon,
  libXrandr,
  libXrender,
  libXtst,
  makeDesktopItem,
  makeWrapper,
  mesa,
  mesa-demos,
  nspr,
  nss,
  pango,
  pkg-config,
  stdenv,
  systemd,
  vulkan-loader,
  wayland,
  xdpyinfo,
  zlib,
}:

let
  pname = "mate-engine";
  version = "3.2.0-6";

  runtimeLibraries = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libayatana-appindicator
    libdrm
    libGL
    libpulseaudio
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXinerama
    libxkbcommon
    libXrandr
    libXrender
    libXtst
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    vulkan-loader
    wayland
    zlib
  ];

  fileBrowserPlugin = stdenv.mkDerivation {
    pname = "mate-engine-standalone-file-browser";
    inherit version;
    src = ./file-browser;

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gtk3 ];
    dontStrip = true;

    buildPhase = ''
      runHook preBuild

      $CC -O2 -Wall -Wextra dialog.c -o dialog $(pkg-config --cflags --libs gtk+-3.0)
      ld -r -b binary -o dialog.bin.o dialog
      objcopy --rename-section .data=.rodata,alloc,load,readonly,data,contents dialog.bin.o
      objcopy --add-section .note.GNU-stack=/dev/null \
        --set-section-flags .note.GNU-stack=noload,readonly dialog.bin.o
      $CC -O2 -Wall -Wextra -fPIC -c library.c -o library.o
      $CC -shared -o libStandaloneFileBrowser.so library.o dialog.bin.o

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 libStandaloneFileBrowser.so \
        $out/lib/libStandaloneFileBrowser.so

      runHook postInstall
    '';
  };

  desktopItem = makeDesktopItem {
    name = "mateengine";
    desktopName = "Mate Engine";
    comment = "Desktop pet with custom VRM support";
    exec = "mateengine";
    icon = "mateengine";
    categories = [ "Game" ];
    keywords = [
      "desktop"
      "pet"
      "anime"
      "vrm"
    ];
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/Marksonthegamer/Mate-Engine-Linux-Port/releases/download/Public-Release-X3.2.0_6/MateEngineX_3.2.0_6.tar.gz";
    hash = "sha256-lJo0RD8bDc8DIxk0GmNQjaipaMYiHA5xyZa43nMH4uA=";
  };

  sourceRoot = "MateEngineX";
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = runtimeLibraries;

  # The optional HIP LLM backend is retained but unavailable on this Intel host.
  autoPatchelfIgnoreMissingDeps = [ "libamdhip64.so.7" ];
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/mate-engine
    cp -R Payload/. $out/libexec/mate-engine/
    install -Dm755 ${fileBrowserPlugin}/lib/libStandaloneFileBrowser.so \
      $out/libexec/mate-engine/MateEngineX_Data/Plugins/libStandaloneFileBrowser.so
    mv $out/libexec/mate-engine/launch.sh $out/libexec/mate-engine/launch-upstream.sh
    install -Dm755 ${./launcher.sh} $out/libexec/mate-engine/launch.sh
    patchShebangs $out/libexec/mate-engine/launch.sh $out/libexec/mate-engine/launch-upstream.sh

    makeWrapper $out/libexec/mate-engine/launch.sh $out/bin/mateengine \
      --set GDK_BACKEND x11 \
      --set GSETTINGS_SCHEMA_DIR ${gtk3}/share/gsettings-schemas/${gtk3.name}/glib-2.0/schemas \
      --set XDG_BACKEND x11 \
      --set SDL_VIDEODRIVER x11 \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gawk
          gnugrep
          jq
          mesa-demos
          xdpyinfo
        ]
      } \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries} \
      --prefix NIX_LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries}

    install -Dm644 \
      $out/libexec/mate-engine/MateEngineX_Data/Resources/UnityPlayer.png \
      $out/share/icons/hicolor/256x256/apps/mateengine.png
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/mateengine.desktop $out/share/applications/

    runHook postInstall
  '';

  meta = {
    description = "Unofficial Linux port of the Mate Engine VRM desktop pet";
    homepage = "https://github.com/Marksonthegamer/Mate-Engine-Linux-Port";
    license = with lib.licenses; [
      agpl3Only
      unfreeRedistributable
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "mateengine";
  };
}
