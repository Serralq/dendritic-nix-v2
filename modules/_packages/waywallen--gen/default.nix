{
  appimageTools,
  fetchFromGitHub,
  fetchurl,
  gettext,
  glslang,
  libGL,
  lz4,
  makeWrapper,
  pkg-config,
  rustPlatform,
  stdenvNoCC,
  unzip,
  vulkan-headers,
  vulkan-loader,
  wayland,
  writeText,
}:

let
  open-wallpaper-engine = stdenvNoCC.mkDerivation {
    pname = "open-wallpaper-engine";
    version = "0.3.0";

    src = fetchurl {
      url = "https://github.com/waywallen/open-wallpaper-engine/releases/download/v0.3.0/org.waywallen.open-wallpaper-engine-0.3.0-linux-x86_64.zip";
      hash = "sha256-LsU6867nf1Y1DpWWRryP3CVzIMpkAALvzX3o4ySudYk=";
    };

    nativeBuildInputs = [ unzip ];
    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      plugin=$out/plugins/org.waywallen.open-wallpaper-engine
      mkdir -p "$plugin"
      unzip "$src" -d "$plugin"

      runHook postInstall
    '';
  };

  display-manifest = writeText "layer-shell.toml" ''
    [display]
    name = "layer-shell"
    bin = "../bin/waywallen-layer-shell"
    de = ["hyprland"]
    priority = 100
    requires = ["wlr-layer-shell", "linux-dmabuf-v4"]
    spawn = "daemon"
  '';

  waywallen-layer-shell = rustPlatform.buildRustPackage {
    pname = "waywallen-layer-shell";
    version = "0.4.0-unstable-2026-10-05";

    src = fetchFromGitHub {
      owner = "waywallen";
      repo = "waywallen-display";
      rev = "0d0ed7a9137afbd0ce4f6ced240f09a091884f78";
      hash = "sha256-sK1JWcmfnUOJYY0mEa0rlBZmtEkqodxG6YN4wCCWYkA=";
    };

    patches = [ ./waywallen-hyprland-pointer.patch ];

    cargoHash = "sha256-TwluLPqS0bSO7ceP4b7BxMfhC04KP09XZkem80fC0Jc=";
    buildNoDefaultFeatures = true;
    buildFeatures = [
      "layer-shell"
      "vulkan"
    ];
    cargoBuildFlags = [ "--bin=waywallen-layer-shell" ];
    cargoTestFlags = [ "--bin=waywallen-layer-shell" ];

    nativeBuildInputs = [
      glslang
      pkg-config
    ];

    buildInputs = [
      gettext
      libGL
      vulkan-headers
      vulkan-loader
      wayland
    ];

    postInstall = ''
      install -Dm644 ${display-manifest} $out/displays/layer-shell.toml
    '';
  };

  pname = "waywallen";
  version = "0.4.4";
  src = fetchurl {
    url = "https://github.com/waywallen/waywallen/releases/download/v${version}/waywallen-${version}-x86_64.AppImage";
    hash = "sha256-P1KWhxhGYFNUiYcRs8ARN/dUsFg5vWJNaacxYfuch8U=";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _: [ lz4 ];

  extraInstallCommands = ''
    source ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/waywallen \
      --add-flags "--plugin ${open-wallpaper-engine}" \
      --add-flags "--plugin ${waywallen-layer-shell}"

    install -Dm644 \
      ${appimageContents}/org.waywallen.waywallen.desktop \
      $out/share/applications/org.waywallen.waywallen.desktop
    install -Dm644 \
      ${appimageContents}/org.waywallen.waywallen.svg \
      $out/share/icons/hicolor/scalable/apps/org.waywallen.waywallen.svg
  '';
}
