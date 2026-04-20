# * Header
{
  config,
  pkgs,
  inputs,
  ...
}:

{
  system.stateVersion = "25.05"; # Did you read the comment?

  # * Imports
  imports = [
  ];
  environment.systemPackages = with pkgs; [
  ];

}

# ABCDEF
