{ pkgs }:

pkgs.appimageTools.wrapType2 {
  pname = "bambu-studio";
  version = "02.05.02.51";
  src = pkgs.fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v02.05.02.51/BambuStudio_ubuntu-24.04_v02.05.02.51-20260327222803.AppImage";
    hash = "sha256-tWda80M3cV5hztEoYkZVGabQMgg6pyc/OniPJfghN0Q=";
  };
  extraPkgs =
    pkgs: with pkgs; [
      webkitgtk_4_1
      glib-networking
      cacert
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-bad
    ];
  extraInstallCommands =
    let
      certs = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      locales = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    in
    ''
      source ${pkgs.makeWrapper}/nix-support/setup-hook
      wrapProgram $out/bin/bambu-studio \
        --set SSL_CERT_FILE "${certs}" \
        --set CURL_CA_BUNDLE "${certs}" \
        --set GIO_EXTRA_MODULES "${pkgs.glib-networking}/lib/gio/modules" \
        --set LOCALE_ARCHIVE "${locales}" \
        --set GDK_BACKEND "x11"
    '';
}
