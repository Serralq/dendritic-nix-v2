{ den, ... }:
{
  den.aspects.home-manager-backups =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          home-manager.backupCommand = pkgs.writeShellScript "home-manager-backup" ''
            set -eu

            target="$1"
            report="''${HOME_MANAGER_BACKUP_REPORT:?Backup report was not initialized}"
            timestamp="$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S)"
            backup="$target.$timestamp.bak"
            suffix=1

            while [[ -e "$backup" || -L "$backup" ]]; do
              backup="$target.$timestamp-$suffix.bak"
              suffix=$((suffix + 1))
            done

            ${pkgs.coreutils}/bin/mv -- "$target" "$backup"
            ${pkgs.coreutils}/bin/printf '%s\n' "$backup" >> "$report"
          '';
          home-manager.sharedModules = [
            (
              {
                config,
                lib,
                pkgs,
                ...
              }:
              {
                home.activation.prepareBackupReport =
                  lib.hm.dag.entryBefore [ "linkGeneration" ]
                    ''
                      report_dir=${lib.escapeShellArg "${config.xdg.stateHome}/home-manager/backup-reports"}
                      run ${pkgs.coreutils}/bin/mkdir -p "$report_dir"

                      if [[ ! -v DRY_RUN ]]; then
                        timestamp="$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S)"
                        report="$report_dir/$timestamp-backup-report"
                        suffix=1

                        while [[ -e "$report" ]]; do
                          report="$report_dir/$timestamp-$suffix-backup-report"
                          suffix=$((suffix + 1))
                        done

                        export HOME_MANAGER_BACKUP_REPORT="$report"
                      fi
                    '';

                home.activation.showBackupReport = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
                  report="''${HOME_MANAGER_BACKUP_REPORT:-}"

                  if [[ ! -v DRY_RUN && -n "$report" && -s "$report" ]]; then
                    count="$(${pkgs.coreutils}/bin/wc -l < "$report")"

                    ${pkgs.coreutils}/bin/printf \
                      '\nHome Manager created %s backup(s):\n' "$count"
                    ${pkgs.coreutils}/bin/cat "$report"
                  fi
                '';
              }
            )
          ];
        };
    };
}
