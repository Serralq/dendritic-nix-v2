{ ... }:
{
  den.aspects.office = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          hunspell
          libreoffice-qt # To read office files
          hunspellDicts.en_US-large
          typst # To write my office files
          typst-live # For live viewing
          typstyle # For formatting
          tinymist # For lsp support
        ];
      };
  };
}
