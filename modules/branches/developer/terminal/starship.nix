{ ... }:
{
  den.aspects.starship = {
    homeManager =
      { ... }:
      {
        xdg.configFile."starship.toml".source = ./starship.toml;
        xdg.configFile."starship/starship.toml".source = ./starship.toml;
        xdg.configFile."starship-yazi.toml".source = ./starship-yazi.toml;
        xdg.configFile."starship/starship-yazi.toml".source = ./starship-yazi.toml;
      };
  };
}
