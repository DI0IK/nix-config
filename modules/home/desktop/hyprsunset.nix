{ pkgs, ... }:
let
  hyprsunsetToggle = pkgs.writeShellScriptBin "hyprsunset-toggle" ''
    set -euo pipefail
    if ${pkgs.procps}/bin/pgrep -x "hyprsunset" >/dev/null; then
      ${pkgs.procps}/bin/pkill -x "hyprsunset"
      ${pkgs.libnotify}/bin/notify-send "Night Light" "Daylight mode (6500K)" -i video-display -a "Hyprsunset"
    else
      ${pkgs.hyprsunset}/bin/hyprsunset -t 3500 &
      ${pkgs.libnotify}/bin/notify-send "Night Light" "Night mode active (3500K)" -i weather-clear-night -a "Hyprsunset"
    fi
  '';
in
{
  home.packages = with pkgs; [
    hyprsunset
    hyprsunsetToggle
  ];
}
