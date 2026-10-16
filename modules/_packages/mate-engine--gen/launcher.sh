#!/usr/bin/env bash

set -u

requested_width=""
requested_height=""
previous_argument=""

for argument in "$@"; do
  case "$previous_argument" in
    -screen-width)
      [[ "$argument" =~ ^[0-9]+$ ]] && requested_width="$argument"
      ;;
    -screen-height)
      [[ "$argument" =~ ^[0-9]+$ ]] && requested_height="$argument"
      ;;
  esac
  previous_argument="$argument"
done

resize_for_unity_minimum() {
  local address current_height current_width height width clients

  for _ in {1..100}; do
    clients="$(env -u LD_LIBRARY_PATH -u NIX_LD_LIBRARY_PATH hyprctl clients -j 2>/dev/null || true)"
    address="$(jq -r 'first(.[] | select(.class == "MateEngineX.x86_64")) | .address // empty' <<< "$clients" 2>/dev/null)"

    if [[ "$address" =~ ^0x[0-9a-fA-F]+$ ]]; then
      current_width="$(jq -r --arg address "$address" 'first(.[] | select(.address == $address)) | .size[0]' <<< "$clients")"
      current_height="$(jq -r --arg address "$address" 'first(.[] | select(.address == $address)) | .size[1]' <<< "$clients")"
      width="${requested_width:-$current_width}"
      height="${requested_height:-$current_height}"

      # Let Mate Engine finish its own initial window setup before overriding Unity's floor.
      sleep 2
      for _ in {1..20}; do
        env -u LD_LIBRARY_PATH -u NIX_LD_LIBRARY_PATH hyprctl eval \
          "hl.dispatch(hl.dsp.window.resize({ x = $width, y = $height, window = \"address:$address\" }))" \
          >/dev/null 2>&1 || true
        sleep 0.25
      done
      return
    fi

    sleep 0.1
  done
}

resizer_pid=""
if [[ -n "$requested_width" && "$requested_width" -lt 500 ]]; then
  resize_for_unity_minimum &
  resizer_pid=$!
fi

cleanup() {
  if [[ -n "$resizer_pid" ]]; then
    kill "$resizer_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

"$(dirname "$(realpath "${BASH_SOURCE[0]}")")/launch-upstream.sh" "$@"
