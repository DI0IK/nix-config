{ pkgs, ... }: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || uwsm app -- hyprlock";

        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 150; # 2.5 minutes
          on-timeout = "brightnessctl -s set 10"; # Dim monitor backlight (OLED friendly)
          on-resume = "brightnessctl -r"; # Restore backlight strength
        }
        {
          timeout = 300; # 5 minutes
          on-timeout = "loginctl lock-session"; # Lock session via systemd logind
        }
        {
          timeout = 330; # 5.5 minutes
          on-timeout = "hyprctl dispatch dpms off"; # Shut down screen signal entirely
          on-resume = "hyprctl dispatch dpms on"; # Turn screen back on on activity
        }
        {
          timeout = 1800; # 30 minutes
          on-timeout = "systemctl suspend"; # Suspend computer
        }
      ];
    };
  };
}
