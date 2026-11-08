{
  config,
  lib,
  pkgs,
  theme ? import ../../shared/theme.nix,
  ...
}:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        position = "top";
        height = 32;
        spacing = 0;

        "modules-left" = [
          "hyprland/workspaces"
          "hyprland/submap"
          "hyprland/window"
        ];
        "modules-center" = [
          "mpris"
          "clock"
        ];
        "modules-right" = [
          "cpu"
          "memory"
          "temperature"
          "pulseaudio"
          "backlight"
          "network"
          "battery"
          "power-profiles-daemon"
          "idle_inhibitor"
          "privacy"
          "custom/notification"
          "tray"
        ];

        "hyprland/workspaces" = {
          "disable-scroll" = true;
          "all-outputs" = true;
          format = "{name}";
          "on-click" = "activate";
        };

        "hyprland/window" = {
          format = "{title}";
          "max-length" = 45;
          "separate-outputs" = true;
        };

        idle_inhibitor = {
          format = "{icon}";
          "format-icons" = {
            activated = "<span color='${theme.mauve}'>󰅶</span>";
            deactivated = "<span color='${theme.overlay1}'>󰾪</span>";
          };
          "tooltip-format-activated" = "Idle Inhibitor: Active";
          "tooltip-format-deactivated" = "Idle Inhibitor: Inactive";
        };

        tray = {
          spacing = 8;
        };

        clock = {
          format = "<span color='${theme.lavender}'>󱑂</span> {:%H:%M  󰃭 %a %d %b}";
          "format-alt" = "<span color='${theme.lavender}'>󱑂</span> {:%H:%M:%S  󰃭 %Y-%m-%d}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            "mode-mon-col" = 3;
            format = {
              months = "<span color='${theme.mauve}'><b>{}</b></span>";
              days = "<span color='${theme.text}'><b>{}</b></span>";
              weeks = "<span color='${theme.teal}'><b>W{}</b></span>";
              weekdays = "<span color='${theme.peach}'><b>{}</b></span>";
              today = "<span color='${theme.red}'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          format = "<span color='${theme.mauve}'>󰻠</span> {usage}%";
          interval = 3;
          tooltip = true;
        };

        memory = {
          format = "<span color='${theme.pink}'>󰍛</span> {percentage}%";
          interval = 3;
          "tooltip-format" =
            "RAM: {used:0.1f}GiB / {total:0.1f}GiB ({percentage}%)\nSwap: {swapUsed:0.1f}GiB / {swapTotal:0.1f}GiB";
        };

        temperature = {
          "critical-threshold" = 80;
          format = "<span color='${theme.teal}'>{icon}</span> {temperatureC}°C";
          "format-critical" = "<span color='${theme.red}'>{icon}</span> {temperatureC}°C";
          "format-icons" = [
            "󱃂"
            "󰔏"
            "󰔐"
          ];
          tooltip = true;
        };

        backlight = {
          format = "<span color='${theme.yellow}'>{icon}</span> {percent}%";
          "format-icons" = [
            "󰃞"
            "󰃟"
            "󰃠"
          ];
          tooltip = false;
          "on-scroll-up" = "${pkgs.brightnessctl}/bin/brightnessctl -e4 set 2%+";
          "on-scroll-down" = "${pkgs.brightnessctl}/bin/brightnessctl -e4 set 2%-";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "<span color='${theme.green}'>{icon}</span> {capacity}%";
          "format-full" = "<span color='${theme.green}'>{icon}</span> {capacity}%";
          "format-charging" = "<span color='${theme.teal}'>󰂄</span> {capacity}%";
          "format-plugged" = "<span color='${theme.teal}'>󱟢</span> {capacity}%";
          "format-alt" = "<span color='${theme.green}'>{icon}</span> {time}";
          "tooltip-format" = "Health: {health}%\nDraw: {power:.1f}W\nTime: {time}\nCycles: {cycles}";
          "format-icons" = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          "format-icons" = {
            notification = "<span color='${theme.red}'>󰂚</span>";
            none = "<span color='${theme.mauve}'>󰂜</span>";
            "dnd-notification" = "<span color='${theme.red}'>󰂛</span>";
            "dnd-none" = "<span color='${theme.overlay1}'>󰂛</span>";
            "inhibited-notification" = "<span color='${theme.red}'>󰂚</span>";
            "inhibited-none" = "<span color='${theme.mauve}'>󰂜</span>";
            "dnd-inhibited-notification" = "<span color='${theme.red}'>󰂛</span>";
            "dnd-inhibited-none" = "<span color='${theme.overlay1}'>󰂛</span>";
          };
          "return-type" = "json";
          exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
          "on-click" = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
          "on-click-right" = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
          escape = true;
        };

        power-profiles-daemon = {
          format = "{icon}";
          "tooltip-format" = "Power Profile: {profile}\nDriver: {driver}";
          tooltip = true;
          "format-icons" = {
            default = "<span color='${theme.sapphire}'></span>";
            performance = "<span color='${theme.red}'></span>";
            balanced = "<span color='${theme.sapphire}'></span>";
            "power-saver" = "<span color='${theme.green}'></span>";
          };
        };

        network = {
          "format-wifi" = "<span color='${theme.peach}'>󰖩</span> {essid} <small>({signalStrength}%)</small>";
          "format-ethernet" = "<span color='${theme.peach}'>󰈀</span> {ifname}";
          "format-disconnected" = "<span color='${theme.red}'>󰖪</span> Disconnected";
          "format-linked" = "<span color='${theme.peach}'>󰈀</span> No IP";
          "tooltip-format" = "Interface: {ifname}\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}";
          "tooltip-format-wifi" =
            "SSID: {essid} ({signalStrength}%)\nInterface: {ifname}\nIP: {ipaddr}/{cidr}\nFrequency: {frequency}MHz";
        };

        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          player-icons = {
            default = "<span color='${theme.mauve}'>󰎆</span>";
            spotify = "<span color='${theme.green}'>󰓇</span>";
          };
          status-icons = {
            paused = "<span color='${theme.overlay1}'>󰏤</span>";
          };
          dynamic-order = [
            "title"
            "artist"
          ];
          dynamic-len = 32;
          dynamic-importance-order = [
            "title"
            "artist"
          ];
          tooltip-format = "{player} ({status})\nTitle: {title}\nArtist: {artist}\nAlbum: {album}";
        };

        privacy = {
          icon-spacing = 6;
          icon-size = 14;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 18;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 18;
            }
          ];
        };

        pulseaudio = {
          format = "<span color='${theme.yellow}'>{icon}</span> {volume}%";
          "format-bluetooth" = "<span color='${theme.yellow}'>{icon}</span> {volume}%";
          "format-muted" = "<span color='${theme.overlay0}'>󰝟</span> Muted";
          "format-icons" = {
            headphone = "󰋋";
            hands-free = "󰋎";
            headset = "󰋎";
            phone = "󰏲";
            phone-muted = "󰏳";
            portable = "󰏲";
            car = "󰄋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          "scroll-step" = 2;
          "on-click" = "uwsm app -- ${pkgs.pavucontrol}/bin/pavucontrol";
        };
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font Propo", "JetBrainsMono Nerd Font", monospace;
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background: transparent;
          color: @text;
      }

      /* Floating Islands */
      .modules-left,
      .modules-center,
      .modules-right {
          background-color: alpha(@mantle, 0.88);
          border: 1px solid alpha(@surface1, 0.45);
          border-radius: 10px;
          padding: 1px 4px;
          margin-top: 5px;
          margin-bottom: 0px;
      }

      .modules-left {
          margin-left: 8px;
      }

      .modules-right {
          margin-right: 8px;
      }

      /* Tooltip */
      tooltip {
          background-color: @base;
          border: 1px solid @surface1;
          border-radius: 8px;
          padding: 6px;
      }

      tooltip label {
          color: @text;
      }

      /* Workspaces */
      #workspaces {
          padding: 0;
          margin: 0;
      }

      #workspaces button {
          min-width: 0;
          padding: 1px 4px;
          margin: 1px 1px;
          border-radius: 5px;
          color: @subtext0;
          background: transparent;
          transition: all 0.2s ease-in-out;
      }

      #workspaces button:hover {
          color: @text;
          background: @surface0;
          box-shadow: none;
          text-shadow: none;
      }

      #workspaces button.active {
          color: @base;
          background-color: @mauve;
          font-weight: bold;
          min-width: 0;
          padding: 1px 6px;
          border-radius: 5px;
          box-shadow: none;
      }

      #workspaces button.urgent {
          color: @base;
          background-color: @red;
          min-width: 0;
      }

      /* Window Title */
      #window {
          padding: 0 6px;
          color: @subtext1;
          font-weight: 500;
      }

      window#waybar.empty #window {
          padding: 0;
          margin: 0;
      }

      /* Submap / Mode */
      #submap,
      #mode {
          background-color: @mauve;
          color: @base;
          padding: 1px 6px;
          margin: 1px 3px;
          border-radius: 5px;
          font-weight: bold;
      }

      /* Center Clock Island */
      #clock {
          padding: 0 8px;
          font-weight: 600;
          color: @text;
      }

      #mpris {
          padding: 1px 8px;
          margin: 1px 3px;
          border-radius: 6px;
          color: @text;
          background-color: alpha(@surface0, 0.45);
          transition: all 0.2s ease-in-out;
      }

      #mpris:hover {
          background-color: alpha(@surface0, 0.8);
      }

      /* Privacy Module */
      #privacy {
          padding: 0 2px;
          margin: 1px 1px;
      }

      #privacy-item {
          padding: 0 2px;
          color: @peach;
      }

      #privacy-item.screenshare {
          color: @red;
      }

      #privacy-item.audio-in {
          color: @pink;
      }

      /* Right Island Modules */
      #cpu,
      #memory,
      #temperature,
      #pulseaudio,
      #backlight,
      #network,
      #battery,
      #power-profiles-daemon,
      #idle_inhibitor,
      #custom-notification,
      #tray,
      #custom-weather,
      #custom-kernel,
      #custom-timetracker,
      #custom-android_extend {
          padding: 1px 4px;
          margin: 1px 0px;
          border-radius: 5px;
          color: @text;
          background: transparent;
          transition: all 0.2s ease-in-out;
      }

      /* Subtle Hover Effect */
      #cpu:hover,
      #memory:hover,
      #temperature:hover,
      #pulseaudio:hover,
      #backlight:hover,
      #network:hover,
      #battery:hover,
      #power-profiles-daemon:hover,
      #idle_inhibitor:hover,
      #custom-notification:hover,
      #clock:hover {
          background-color: alpha(@surface0, 0.6);
      }

      /* Dividers between groups in the right island */
      #temperature {
          margin-right: 4px;
          padding-right: 6px;
          border-right: 1px solid alpha(@surface1, 0.5);
      }

      #backlight {
          margin-right: 4px;
          padding-right: 6px;
          border-right: 1px solid alpha(@surface1, 0.5);
      }

      #power-profiles-daemon {
          margin-right: 4px;
          padding-right: 6px;
          border-right: 1px solid alpha(@surface1, 0.5);
      }

      /* Status States */
      #battery.warning {
          color: @yellow;
      }

      #battery.critical {
          color: @red;
          animation-name: blink;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #temperature.critical {
          color: @red;
      }

      #pulseaudio.muted {
          color: @overlay0;
      }

      #network.disconnected {
          color: @red;
      }

      @keyframes blink {
          to {
              color: @maroon;
          }
      }

      /* Tray */
      #tray {
          padding: 0 4px;
          margin: 2px 2px;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: alpha(@red, 0.25);
          border-radius: 4px;
      }
    '';
  };
}
