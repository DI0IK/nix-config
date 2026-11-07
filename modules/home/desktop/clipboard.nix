{ pkgs, lib, ... }:
let
  cliphistWatcher = pkgs.writeShellScriptBin "cliphist-watcher" ''
    set -euo pipefail
    export XDG_CACHE_HOME="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cache"
    mkdir -p "$XDG_CACHE_HOME/cliphist"

    # Watch and store text, ignoring password manager payloads
    ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch bash -c '
      types=$(${pkgs.wl-clipboard}/bin/wl-paste --list-types 2>/dev/null || true)
      if echo "$types" | ${pkgs.gnugrep}/bin/grep -qiE "x-kde-passwordManagerHint|password|secret"; then
        exit 0
      fi
      exec ${pkgs.cliphist}/bin/cliphist store
    ' &

    # Watch and store images, ignoring password manager payloads
    ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch bash -c '
      types=$(${pkgs.wl-clipboard}/bin/wl-paste --list-types 2>/dev/null || true)
      if echo "$types" | ${pkgs.gnugrep}/bin/grep -qiE "x-kde-passwordManagerHint|password|secret"; then
        exit 0
      fi
      exec ${pkgs.cliphist}/bin/cliphist store
    '
  '';

  cliphistFuzzel = pkgs.writeShellScriptBin "cliphist-fuzzel" ''
    set -euo pipefail
    export XDG_CACHE_HOME="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cache"
    selected=$(${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="󱘲    " --placeholder="Search clipboard history...")
    if [ -n "$selected" ]; then
      echo "$selected" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
    fi
  '';

  cliphistWipe = pkgs.writeShellScriptBin "cliphist-wipe" ''
    set -euo pipefail
    export XDG_CACHE_HOME="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cache"
    ${pkgs.cliphist}/bin/cliphist wipe
    ${pkgs.wl-clipboard}/bin/wl-copy --clear
    ${pkgs.libnotify}/bin/notify-send "Clipboard" "Clipboard history wiped securely" -i edit-clear
  '';
in
{
  home.packages = with pkgs; [
    cliphist
    cliphistFuzzel
    cliphistWipe
  ];

  systemd.user.services.cliphist = {
    Unit = {
      Description = "Secure in-memory clipboard history daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [ "XDG_CACHE_HOME=%t/cache" ];
      ExecStart = "${cliphistWatcher}/bin/cliphist-watcher";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
