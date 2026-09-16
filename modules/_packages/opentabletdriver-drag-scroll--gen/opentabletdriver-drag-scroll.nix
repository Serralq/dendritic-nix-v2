{
  dotnetCorePackages,
  opentabletdriver,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "opentabletdriver-drag-scroll";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ dotnetCorePackages.sdk_8_0 ];

  buildPhase = ''
    runHook preBuild

    export DOTNET_CLI_HOME="$TMPDIR/dotnet"
    dotnet restore --ignore-failed-sources \
      -p:OpenTabletDriverPath=${opentabletdriver}
    dotnet build --no-restore --configuration Release \
      -p:OpenTabletDriverPath=${opentabletdriver}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 bin/Release/net8.0/OpenTabletDriver.DragScroll.dll \
      $out/lib/opentabletdriver-plugins/DragScroll.dll
    install -Dm644 metadata.json \
      $out/lib/opentabletdriver-plugins/metadata.json

    runHook postInstall
  '';
}
