{ den, ... }:
{
  den.aspects.cloudflare =
    { ... }:
    {
      includes = [ den.aspects.networking ];

      nixos =
        { ... }:
        {
          services.cloudflared.enable = true;
        };

      homeManager =
        { pkgs, ... }:
        {
          home.packages = [ pkgs.cloudflared ]; # Allow for external links
        };
    };
}
