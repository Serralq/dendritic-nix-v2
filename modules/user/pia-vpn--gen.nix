{ den, ... }:
{
  den.aspects.pia-vpn =
    { user, ... }:
    let
      pia-state-file = "/home/${user.userName}/.local/state/pia-vpn/last-server.tsv";
    in
    {
      includes = [
        den.aspects.security
        den.aspects.networking
      ];
      nixos =
        { config, pkgs, ... }:
        let
          pia-ca = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/pia-foss/manual-connections/master/ca.rsa.4096.crt";
            hash = "sha256-Mumx0UM+qXYU8qFMbjWOP1fAVwzJ9rLugSaZumlsZqs=";
          };
          secretName = "${user.userName}-openvpn-auth";
        in
        {

          sops.secrets.${secretName}.key = "users/${user.userName}/openvpn-auth";
          networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

          # ** PIA VPN
          systemd.services.pia-vpn-profile = {
            description = "Load the PIA OpenVPN profile into NetworkManager";
            wantedBy = [ "multi-user.target" ];
            after = [
              "NetworkManager.service"
              "network-online.target"
            ];
            wants = [ "network-online.target" ];
            requires = [ "NetworkManager.service" ];

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };

            script = ''
              set -eu

              runtime_dir="$(${pkgs.coreutils}/bin/mktemp -d /run/pia-vpn.XXXXXX)"
              trap '${pkgs.coreutils}/bin/rm -rf "$runtime_dir"' EXIT

              {
                IFS= read -r username
                IFS= read -r password
              } < ${config.sops.secrets.${secretName}.path}

              if [ -z "$username" ] || [ -z "$password" ]; then
                echo "The PIA authentication secret must contain a username and password"
                exit 1
              fi

              region_id="us-newjersey"
              region_name="US East"
              server_ip=""
              certificate_name=""
              location_type="Physical"
              port_forwarding="No PF"
              country_code="us"

              if [ -r ${pia-state-file} ]; then
                IFS="$(printf '\t')" read -r \
                  region_id region_name server_ip certificate_name \
                  location_type port_forwarding country_code \
                  < ${pia-state-file}
              fi

              region_data="$(${pkgs.curl}/bin/curl \
                --fail --silent --show-error --max-time 20 \
                https://serverlist.piaservers.net/vpninfo/servers/v6 \
                | ${pkgs.jq}/bin/jq --raw-input --raw-output \
                  --arg region_id "$region_id" '
                    fromjson?
                    | .regions[]
                    | select(.id == $region_id and .offline == false)
                    | select((.servers.ovpntcp // []) | length > 0)
                    | [
                        .name,
                        .servers.ovpntcp[0].ip,
                        .servers.ovpntcp[0].cn,
                        (if .geo then "Virtual" else "Physical" end),
                        (if .port_forward then "PF" else "No PF" end),
                        (.country | ascii_downcase)
                      ]
                    | @tsv
                  ' || true)"

              if [ -n "$region_data" ]; then
                IFS="$(printf '\t')" read -r \
                  region_name server_ip certificate_name location_type port_forwarding country_code \
                  <<EOF
              $region_data
              EOF
              fi

              if [ -z "$server_ip" ] || [ -z "$certificate_name" ]; then
                echo "Unable to resolve PIA region '$region_id' and no cached endpoint is available"
                exit 1
              fi

              ${pkgs.coreutils}/bin/install -d -m 700 \
                -o ${user.userName} -g users \
                /home/${user.userName}/.local/state/pia-vpn
              ${pkgs.coreutils}/bin/printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                "$region_id" "$region_name" "$server_ip" "$certificate_name" \
                "$location_type" "$port_forwarding" "$country_code" \
                > "$runtime_dir/last-server.tsv"
              ${pkgs.coreutils}/bin/install -m 600 \
                -o ${user.userName} -g users \
                "$runtime_dir/last-server.tsv" ${pia-state-file}

              {
                echo "client"
                echo "dev tun"
                echo "proto tcp"
                echo "remote $server_ip 443"
                echo "cipher aes-256-cbc"
                echo "auth sha256"
                echo "data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305"
                echo "remote-cert-tls server"
                echo "verify-x509-name $certificate_name name"
                echo "auth-user-pass"
                echo "reneg-sec 0"
                echo "ca ${pia-ca}"
              } > "$runtime_dir/PIA-generated.ovpn"

              # The imported profile and its credentials exist only in NetworkManager's memory.
              ${pkgs.networkmanager}/bin/nmcli connection delete id "PIA VPN" >/dev/null 2>&1 || true
              ${pkgs.networkmanager}/bin/nmcli connection import \
                --temporary type openvpn file "$runtime_dir/PIA-generated.ovpn"
              ${pkgs.networkmanager}/bin/nmcli connection modify \
                --temporary id "PIA-generated" \
                connection.id "PIA VPN" \
                connection.autoconnect no \
                vpn.user-name "$username" \
                +vpn.data "password-flags=0" \
                vpn.secrets "password=$password"
            '';
          };

        };

      # ** PIA VPN TUI
      homeManager =
        { pkgs, ... }:
        let
          pia-vpn-script = pkgs.writeShellApplication {
            name = "pia-vpn";
            runtimeInputs = with pkgs; [
              coreutils
              curl
              fzf
              jq
              networkmanager
            ];
            text = ''
              set -euo pipefail

              profile="PIA VPN"
              server_list_url="https://serverlist.piaservers.net/vpninfo/servers/v6"
              state_file="${pia-state-file}"
              openvpn_port=443
              benchmark_dir=""

              cleanup() {
                if [[ -n "$benchmark_dir" ]]; then
                  rm -rf "$benchmark_dir"
                fi
              }

              usage() {
                cat <<'EOF'
              Usage: pia-vpn [select|fastest|status|disconnect|list]

                select      Choose a PIA region with fzf and connect (default)
                fastest     Benchmark all regions and connect to the fastest
                status      Show whether the PIA VPN is connected
                disconnect  Disconnect the PIA VPN
                list        Print currently available PIA regions
              EOF
              }

              profile_uuid() {
                nmcli --get-values connection.uuid connection show id "$profile" 2>/dev/null || {
                  echo "The '$profile' NetworkManager profile is unavailable." >&2
                  echo "Check: systemctl status pia-vpn-profile" >&2
                  return 1
                }
              }

              is_active() {
                local active_uuid
                local uuid="$1"

                while IFS= read -r active_uuid; do
                  if [[ "$active_uuid" == "$uuid" ]]; then
                    return 0
                  fi
                done < <(nmcli --get-values UUID connection show --active)

                return 1
              }

              fetch_regions() {
                local regions

                regions="$({
                  curl --fail --silent --show-error --max-time 20 "$server_list_url" || exit 1
                } | jq --raw-input --raw-output '
                  fromjson?
                  | [
                      .regions[]
                      | select(.offline == false)
                      | select((.servers.ovpntcp // []) | length > 0)
                      | select((.servers.meta // []) | length > 0)
                    ]
                  | sort_by(.name)
                  | .[]
                  | [
                      .id,
                      .name,
                      .servers.ovpntcp[0].ip,
                      .servers.ovpntcp[0].cn,
                      (if .geo then "Virtual" else "Physical" end),
                      (if .port_forward then "PF" else "No PF" end),
                      (.country | ascii_downcase),
                      .servers.meta[0].ip
                    ]
                  | @tsv
                ')"

                if [[ -z "$regions" ]]; then
                  echo "PIA returned no usable OpenVPN TCP regions." >&2
                  return 1
                fi

                printf '%s\n' "$regions"
              }

              connect_region() {
                local id="$1"
                local name="$2"
                local ip="$3"
                local certificate_name="$4"
                local location_type="$5"
                local port_forwarding="$6"
                local country_code="$7"
                local uuid

                uuid="$(profile_uuid)"

                if is_active "$uuid"; then
                  echo "Disconnecting the current PIA connection..."
                  nmcli connection down uuid "$uuid" >/dev/null
                fi

                nmcli connection modify --temporary uuid "$uuid" \
                  +vpn.data "remote=$ip:$openvpn_port" \
                  +vpn.data "verify-x509-name=name:$certificate_name" \
                  -vpn.data compress

                printf 'Connecting to %s (%s, %s, %s)...\n' \
                  "$name" "$id" "$location_type" "$port_forwarding"
                nmcli --pretty connection up uuid "$uuid"

                state_dir="$(dirname "$state_file")"
                install --directory --mode 700 "$state_dir"
                state_tmp="$(mktemp --tmpdir="$state_dir" .last-server.XXXXXX)"
                printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                  "$id" "$name" "$ip" "$certificate_name" \
                  "$location_type" "$port_forwarding" "$country_code" \
                  > "$state_tmp"
                chmod 600 "$state_tmp"
                mv "$state_tmp" "$state_file"
              }

              select_region() {
                local regions="$1"
                local candidates selection display _display
                local id name ip certificate_name location_type port_forwarding country_code _meta_ip

                candidates="$(
                  while IFS=$'\t' read -r \
                    id name ip certificate_name location_type port_forwarding country_code _meta_ip; do
                    display="$(printf '%-36s %-10s %s' "$name" "$location_type" "$port_forwarding")"
                    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                      "$display" "$id" "$name" "$ip" "$certificate_name" \
                      "$location_type" "$port_forwarding" "$country_code" "$_meta_ip"
                  done <<< "$regions"
                )"

                selection="$(
                  printf '%s\n' "$candidates" | fzf \
                    --delimiter=$'\t' \
                    --with-nth=1 \
                    --layout=reverse \
                    --border \
                    --header="$(printf '%-36s %-10s %s' 'Location' 'Type' 'Port forwarding')" \
                    --prompt='PIA region> '
                )" || exit 130

                IFS=$'\t' read -r \
                  _display id name ip certificate_name location_type port_forwarding country_code _meta_ip \
                  <<< "$selection"

                connect_region \
                  "$id" "$name" "$ip" "$certificate_name" "$location_type" "$port_forwarding" "$country_code"
              }

              fastest_region() {
                local regions="$1"
                local id name ip certificate_name location_type port_forwarding country_code meta_ip
                local latency best
                local index=0
                local running=0
                local results=()

                benchmark_dir="$(mktemp --directory --tmpdir pia-vpn-latency.XXXXXX)"
                trap cleanup EXIT

                echo "Benchmarking PIA regions..." >&2
                while IFS=$'\t' read -r \
                  id name ip certificate_name location_type port_forwarding country_code meta_ip; do
                  index=$((index + 1))
                  (
                    latency="$(
                      curl --output /dev/null --silent \
                        --connect-timeout 1 --max-time 1 \
                        --write-out '%{time_connect}' \
                        "http://$meta_ip:443" || true
                    )"

                    if [[ -n "$latency" && "$latency" != "0.000000" ]]; then
                      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                        "$latency" "$id" "$name" "$ip" "$certificate_name" \
                        "$location_type" "$port_forwarding" "$country_code" \
                        > "$benchmark_dir/$index"
                    fi
                  ) &

                  running=$((running + 1))
                  if ((running >= 32)); then
                    wait
                    running=0
                  fi
                done <<< "$regions"
                wait

                shopt -s nullglob
                results=("$benchmark_dir"/*)
                shopt -u nullglob
                if ((''${#results[@]} == 0)); then
                  echo "No PIA region responded to the latency test." >&2
                  return 1
                fi

                best="$(sort --numeric-sort "''${results[@]}" | {
                  IFS= read -r first
                  printf '%s' "$first"
                })"

                IFS=$'\t' read -r \
                  latency id name ip certificate_name location_type port_forwarding country_code \
                  <<< "$best"

                rm -rf "$benchmark_dir"
                benchmark_dir=""
                trap - EXIT

                printf 'Fastest region: %s (%s ms)\n' \
                  "$name" "$(jq --null-input "$latency * 1000 | round")"
                connect_region \
                  "$id" "$name" "$ip" "$certificate_name" "$location_type" "$port_forwarding" "$country_code"
              }

              show_status() {
                local uuid

                uuid="$(profile_uuid)"
                if is_active "$uuid"; then
                  echo "PIA VPN is connected."
                  nmcli --fields GENERAL.NAME,GENERAL.STATE,GENERAL.DEVICES \
                    connection show --active uuid "$uuid"
                else
                  echo "PIA VPN is disconnected."
                fi
              }

              disconnect() {
                local uuid

                uuid="$(profile_uuid)"
                if is_active "$uuid"; then
                  nmcli connection down uuid "$uuid"
                else
                  echo "PIA VPN is already disconnected."
                fi
              }

              list_regions() {
                local regions="$1"
                local id name _ip _certificate_name location_type port_forwarding _country_code _meta_ip

                printf '%-56s %-10s %s\n' "LOCATION" "TYPE" "PORT FORWARDING"
                while IFS=$'\t' read -r \
                  id name _ip _certificate_name location_type port_forwarding _country_code _meta_ip; do
                  printf '%-56s %-10s %s\n' "$name ($id)" "$location_type" "$port_forwarding"
                done <<< "$regions"
              }

              command="''${1:-select}"
              case "$command" in
                select)
                  select_region "$(fetch_regions)"
                  ;;
                fastest)
                  fastest_region "$(fetch_regions)"
                  ;;
                status)
                  show_status
                  ;;
                disconnect)
                  disconnect
                  ;;
                list)
                  list_regions "$(fetch_regions)"
                  ;;
                help | --help | -h)
                  usage
                  ;;
                *)
                  usage >&2
                  exit 2
                  ;;
              esac
            '';
          };

          pia-vpn-completions = pkgs.writeText "pia-vpn.fish" ''
            complete -c pia-vpn -f
            complete -c pia-vpn -n '__fish_use_subcommand' -a select -d 'Choose a PIA region and connect'
            complete -c pia-vpn -n '__fish_use_subcommand' -a fastest -d 'Connect to the lowest-latency PIA region'
            complete -c pia-vpn -n '__fish_use_subcommand' -a status -d 'Show the PIA VPN connection status'
            complete -c pia-vpn -n '__fish_use_subcommand' -a disconnect -d 'Disconnect the PIA VPN'
            complete -c pia-vpn -n '__fish_use_subcommand' -a list -d 'List available PIA regions'
            complete -c pia-vpn -s h -l help -d 'Show command help'
          '';

          pia-vpn = pkgs.symlinkJoin {
            name = "pia-vpn";
            paths = [ pia-vpn-script ];
            postBuild = ''
              mkdir -p $out/share/fish/vendor_completions.d
              ln -s ${pia-vpn-completions} $out/share/fish/vendor_completions.d/pia-vpn.fish
            '';
            meta.mainProgram = "pia-vpn";
          };
        in
        {
          # ** Regular Packages
          home.packages = with pkgs; [
            pia-vpn # Select and manage PIA VPN regions
            openvpn # VPN use
          ];
        };
    };
}
