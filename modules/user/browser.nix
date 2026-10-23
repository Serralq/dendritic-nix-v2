{ ... }:
{
  den.aspects.browser =
    { ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            brave # Ad-blocking
            google-chrome # Compadibility
            (vivaldi.override {
              # Main browser
              proprietaryCodecs = true;
              enableWidevine = true;
            })
            bitwarden-desktop # For website passwords
          ];

          xdg.mimeApps = {
            enable = true;
            defaultApplications = {
              # Web content
              "text/html" = "vivaldi-stable.desktop";
              "application/xhtml+xml" = "vivaldi-stable.desktop";
              "x-scheme-handler/http" = "vivaldi-stable.desktop";
              "x-scheme-handler/https" = "vivaldi-stable.desktop";
              "x-scheme-handler/ftp" = "vivaldi-stable.desktop";

              # Images
              "image/jpeg" = "vivaldi-stable.desktop";
              "image/png" = "vivaldi-stable.desktop";
              "image/gif" = "vivaldi-stable.desktop";
              "image/webp" = "vivaldi-stable.desktop";
              "image/svg+xml" = "vivaldi-stable.desktop";
              "image/bmp" = "vivaldi-stable.desktop";
              "image/tiff" = "vivaldi-stable.desktop";

              # Documents
              "application/pdf" = "vivaldi-stable.desktop";
              "application/xml" = "vivaldi-stable.desktop";
              "text/xml" = "vivaldi-stable.desktop";
              "text/plain" = "vivaldi-stable.desktop";
            };
          };
        };
    };
}
