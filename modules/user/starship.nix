{ ... }:
{
  den.aspects.starship = { user, ... }: {
    homeManager =
      { ... }:
      {
        xdg.configFile."starship.toml".source = user.externals + "/starship.toml";
        xdg.configFile."starship/starship.toml".source = user.externals + "/starship.toml";
        xdg.configFile."starship-yazi.toml".source = user.externals + "/starship-yazi.toml";
        xdg.configFile."starship/starship-yazi.toml".source = user.externals + " /starship-yazi.toml";
      };
  };
}
