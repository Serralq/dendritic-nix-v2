# * Workflow
# - Encrypt: file +format
# - Decrypt: key into empty var or echo $envar
#   - Nix: empty variable
# - Edit: use sops <file> to edit it
{ inputs, ... }:
{
  den.aspects.security = { user, ... }: {
    flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        osConfig = config;
      in
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];
        sops.defaultSopsFile = "${inputs.self}/secrets/secrets.yaml";
        sops.defaultSopsFormat = "yaml";
        sops.age.keyFile = "${config.users.users.${user.userName}.home}/.config/sops/age/keys.txt";

        security.polkit.enable = true;
        environment.systemPackages = [ pkgs.sops ];

        # ** Availible to export to fish (from var-var to VAR_VAR) (--gen)
        home-manager.sharedModules = [
          (
            { config, ... }:
            let
              secrets = lib.filterAttrs (_: secret: secret.owner == config.home.username) osConfig.sops.secrets;
              exports = lib.mapAttrsToList (name: secret: {
                variable = lib.toUpper (builtins.replaceStrings [ "-" ] [ "_" ] name);
                path = secret.path;
              }) secrets;
              names = map (secret: secret.variable) exports;
              cases = lib.concatMapStringsSep "\n" (secret: ''
                case ${lib.escapeShellArg secret.variable}
                    set secret_file ${lib.escapeShellArg secret.path}
              '') exports;
            in
            {
              assertions = [
                {
                  assertion =
                    builtins.length names == builtins.length (lib.unique names)
                    && builtins.all (
                      name: builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null && name != "SOPS_EXPORTED_VARIABLES"
                    ) names;
                  message = "User SOPS secret names must map to unique, valid environment variables other than SOPS_EXPORTED_VARIABLES.";
                }
              ];
              xdg.configFile."fish/functions/sops-export--gen.fish".text =
                builtins.replaceStrings [ "@secret-cases@" "@jq@" ] [ cases "${pkgs.jq}/bin/jq" ]
                  (builtins.readFile (user.externals + "/sops-export--gen.fish"));
              xdg.configFile."fish/completions/sops-export--gen.fish".text = ''
                complete --command sops-export --no-files
                ${lib.concatMapStringsSep "\n" (secret: ''
                  complete --command sops-export --condition '__fish_is_nth_token 1' --arguments ${lib.escapeShellArg secret.variable} --description 'Export user SOPS secret'
                '') exports}
                complete --command sops-export --condition '__fish_is_nth_token 2' --force-files
                complete --command sops-export --long-option help --short-option h --description 'Show usage'
              '';
            }
          )
        ];
      };
  };
}
