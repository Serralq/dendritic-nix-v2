{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  languages.nix.enable = true;
  languages.nix.lsp.enable = true;
}
