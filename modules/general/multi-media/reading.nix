{ pkgs, lib, ... }:

{
  den.aspects.reading = { config, ... }: {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        foliate # Epub reader
        anki # Jp study
        mokuro # To read jp manga
        # Requires pdf to png
        # May require a delete and reinstall
        # Don't touch after it starts running
        # On intel gpu will take literal days for a book
      ];
    };
  };
}
