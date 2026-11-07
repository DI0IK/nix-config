{
  pkgs,
  lib,
  ...
}:
let
  switchProfile = pkgs.writeShellScriptBin "switch-profile" ''
    set -euo pipefail
    profile="''${1:-}"
    if [ -z "$profile" ]; then
      echo "Usage: switch-profile <default|gaming|eco>"
      exit 1
    fi

    if [ "$profile" = "default" ]; then
      echo "Switching to default system configuration..."
      run0 /run/current-system/bin/switch-to-configuration test
      systemctl --user restart hyprpolkitagent.service 2>/dev/null || true
      ${pkgs.libnotify}/bin/notify-send "System Profile" "Switched to: default" -i preferences-system || true
      echo "Switched to default configuration."
    elif [ -d "/run/current-system/specialisation/$profile" ]; then
      echo "Switching to specialisation '$profile'..."
      run0 "/run/current-system/specialisation/$profile/bin/switch-to-configuration" test
      systemctl --user restart hyprpolkitagent.service 2>/dev/null || true
      ${pkgs.libnotify}/bin/notify-send "System Profile" "Switched to: $profile" -i preferences-system || true
      echo "Switched to specialisation '$profile'."
    else
      echo "Error: Unknown profile '$profile'."
      echo "Available profiles: default, gaming, eco"
      exit 1
    fi
  '';
in
{
  environment.systemPackages = [ switchProfile ];

  specialisation = {
    gaming.configuration = {
      # Performance governor for AMD Zen 4 cores
      powerManagement.cpuFreqGovernor = lib.mkForce "performance";

      boot.kernel.sysctl = {
        # Required to prevent memory allocation exhaustion in demanding Steam Proton games
        "vm.max_map_count" = 2147483642;
        "fs.file-max" = 2097152;
        # Reduce latency spikes from split locks in modern gaming
        "kernel.split_lock_mitigate" = 0;
      };

      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            renice = 10;
          };
          custom = {
            start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimized gaming performance active' -i input-gaming";
            end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Returned to normal performance' -i input-gaming";
          };
        };
      };
    };

    eco.configuration = {
      # Extreme battery saver for train or flight travel
      powerManagement.cpuFreqGovernor = lib.mkForce "powersave";

      # Disable background virtualization daemons
      virtualisation.containers.enable = lib.mkForce false;
      virtualisation.podman.enable = lib.mkForce false;

      # Disable CPU boost on AMD
      systemd.tmpfiles.rules = [
        "w /sys/devices/system/cpu/cpufreq/boost - - - - 0"
      ];
    };
  };
}
