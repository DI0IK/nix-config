{ config, lib, pkgs, theme, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        position = "bottom";
        height = 30;
        spacing = 4;

        "modules-left" = [ "hyprland/workspaces" "hyprland/submap" ];
        "modules-center" = [ "hyprland/window" ];
        "modules-right" = [
          "idle_inhibitor"
          "network"
          "power-profiles-daemon"
          "cpu"
          "memory"
          "temperature"
          "backlight"
          "pulseaudio"
          "battery"
          "clock"
          "tray"
        ];

        "hyprland/workspaces" = {
          "disable-scroll" = true;
          "all-outputs" = true;
          format = "{name}: {icon} ";
          "format-icons" = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            urgent = "!";
            default = "-";
          };
        };

        idle_inhibitor = {
          format = "{icon} ";
          "format-icons" = {
            activated = "";
            deactivated = "";
          };
        };

        tray = {
          spacing = 10;
        };

        clock = {
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          "format-alt" = "{:%Y-%m-%d}";
        };

        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };

        memory = {
          format = "{}% ";
        };

        temperature = {
          "critical-threshold" = 80;
          format = "{temperatureC}°C {icon}";
          "format-icons" = ["" "" ""];
        };

        backlights = {
          format = "{percent}% {icon}";
          "format-icons" = ["" "" "" "" "" "" "" "" ""]; 
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          "format-full" = "{capacity}% {icon}";
          "format-charging" = "{capacity}% 󰂄";
          "format-plugged" = "{capacity}% 󱟢";
          "format-alt" = "{time} {icon}";
          "format-icons" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        };

        power-profiles-daemon = {
          format = "{icon}";
          "format-icons" = {
            default = "";
            performance = "";
            balanced = "";
            "power-saver" = "";
          };
        };

        network = {
          "format-wifi" = "{essid} {signalStrength}%";
          "format-ethernet" = "{ifname} {ipaddr}";
          "format-disconnected" = "Disconnected";
          "format-linked" = "{ifname} No IP";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          "format-bluetooth" = "{volume}% {icon}";
          "format-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "headset" = "";
            "phone" = "";
            "phone-muted" = "";
            "portable" = "";
            "car" = "";
            "default" = ["" ""];
          };
          "scroll-step" = 1;
        };
      };
    };

    style = ''
      @define-color base     ${theme.base};
      @define-color mantle   ${theme.mantle};
      @define-color crust    ${theme.crust};
      @define-color text     ${theme.text};
      @define-color surface0 ${theme.surface0};
      @define-color surface1 ${theme.surface1};
      @define-color overlay0 ${theme.overlay0};
      @define-color red      ${theme.red};
      @define-color pink     ${theme.pink};
      @define-color mauve    ${theme.mauve};
      @define-color blue     ${theme.blue};
      @define-color sapphire ${theme.sapphire};
      @define-color cyan     ${theme.cyan};
      @define-color teal     ${theme.teal};
      @define-color green    ${theme.green};
      @define-color yellow   ${theme.yellow};
      @define-color peach    ${theme.peach};
      @define-color maroon   ${theme.maroon};


      * {
          border: none;
          border-radius: 1px;
          font-family: FiraCode Nerd Font;
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          color: @text;
          all:unset;
      }

      .modules-left,
      .modules-center,
      .modules-right {
          background-color: @mantle;
          margin: 5px;
          margin-top: 0;
          border-radius: 7px;
          padding-left: 3px;
          padding-right: 3px;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      tooltip {
          background-color: @base;
          border: 1px solid @surface1;
      }

      tooltip label {
          color: @text;
      }

      button {
          box-shadow: inset 0 -3px transparent;
          border: none;
          border-radius: 1;
      }

      button:hover {
          background: inherit;
          box-shadow: inset 0 -3px @text;
      }

      #workspaces button {
          padding: 0 0;
          background-color: @mantle;
          color: @text;
          margin: 4px 1px;
      }

      #workspaces button:hover {
          box-shadow: inherit;
          text-shadow: inherit;
          background-image: linear-gradient(0deg, @surface1, @mantle);
      }

      #workspaces button.focused {
          background-image: linear-gradient(0deg, @mauve, @surface1);
          box-shadow: inset 0 -3px @text;
      }

      #workspaces button.urgent {
          background-image: linear-gradient(0deg, @red, @mantle);
      }

      #taskbar button.active {
          background-image: linear-gradient(0deg, @surface1, @mantle);
      }

      #mode {
          background-color: @base;
          box-shadow: inset 0 -2px @text;
      }

      #mpris,
      #custom-weather,
      #clock,
      #language,
      #pulseaudio,
      #bluetooth,
      #network,
      #memory,
      #cpu,
      #temperature,
      #disk,
      #custom-kernel,
      #idle_inhibitor,
      #custom-android_extend,
      #custom-timetracker,
      #scratchpad,
      #mode,
      #tray,
      #battery,
      #backlight,
      #power-profiles-daemon {
          padding: 0 10px;
          margin: 4px 1px;
          border-radius: 3px;
      }  

      #window,
      #workspaces {
          margin: 0 4px;
      }  

      #custom-weather {
          background-color: @teal;
          color: @mantle;
          margin-right: 5px;
      }  

      #custom-kernel {
          background-color: @rosewater;
          color: @mantle;
      }  

      #clock {
          background-color: @green;
          color: @mantle;
      }  

      @keyframes blink {
          to {
              background-color: @mantle;
              color: @text;
          }
      }  

      label:focus {
          background-color: @mantle;
      }  

      #cpu {
          background-color: @mauve;
          color: @mantle;
      }  

      #memory {
          background-color: @red;
          color: @mantle;
      }
      #power-profiles-daemon {
          background-color: @sapphire;
          color: @mantle;
      }
      
      #backlight {
          background-color: @teal;
          color: @mantle;
      }
      
      #battery {
          background-color: @green;
          color: @mantle;
      }
      #battery.warning {
          background-color: @yellow;
          color: @mantle;
      }
      #battery.critical {
          background-color: @maroon;
          color: @mantle;
      }
      
      #disk {
          background-color: @flamingo;
          color: @mantle;
      }
      
      #network {
          background-color: @peach;
          color: @mantle;
      }
      
      #network.disconnected {
          background-color: red;
          color: @mantle;
      }
      
      #bluetooth {
          background-color: @maroon;
          color: @mantle;
      }
      
      #pulseaudio {
          background-color: @yellow;
          color: @mantle;
      }
      
      #pulseaudio.muted {
          background-color: red;
          color: @mantle;
      }
      #temperature {
          background-color: @pink;
          color: @mantle;
      }
      
      #temperature.critical {
          background-color: red;
          color: @mantle;
      }
      
      #mpris {
          background-color: @base;
          color: @text;
      }
      
      #tray {
          background-color: @overlay0;
          color: @text;
      }
      
      #tray > .passive {
          -gtk-icon-effect: dim;
      }
      
      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: @mantle;
      }
      
      #idle_inhibitor {
          background-color: @base;
          color: @text;
      }
      
      #idle_inhibitor.activated {
          background-color: @text;
          color: @base;
      }
      #custom-android_extend.disabled {
          background-color: @base;
          color: @text;
      }
      #custom-android_extend.enabled {
          background-color: @green;
          color: @mantle;
      }
      
      #scratchpad {
          background-color: @base;
          color: @text;
      }
      
      #scratchpad.empty {
          background-color: transparent;
      }
      
      #custom-timetracker {
          /* Use mauve for the background when the module is present but not in a specific state, 
             or mantle if you want a dark background that matches the bar. */
          background-color: @base; 
          color: @text;
          padding: 0 10px;
      }
      
      #custom-timetracker.running {
          /* Bright green for active tracking */
          background-color: @green;
          color: @base; /* Black text on green background */
          font-weight: bold;
      }
      
      #custom-timetracker.inactive {
          /* Mauve accent when the timer is off (Clock In) */
          background-color: @mauve;
          color: @base; /* Black text on mauve background */
      }
      
      #custom-timetracker.error {
          /* Red for corrupted state */
          background-color: @red;
          color: @base;
      }
      
      #custom-timetracker.paused {
        /* Yellow for paused state */
        background-color: @yellow;
        color: @base; /* Black text on yellow background */
      }
    '';
  };
}
