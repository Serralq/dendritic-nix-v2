{ ... }:
{
  den.aspects.office =
    { ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            hunspell
            libreoffice-qt
            hunspellDicts.en_US-large
          ];
        };
    };
}
