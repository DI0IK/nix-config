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

        "modules-left" = [ "hyprland/workspaces" ];
        "modules-center" = [ "hyprland/window" ];
        "modules-right" = [
          "idle_inhibitor"
          "network"
          "cpu"
          "memory"
          "temperature"
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
            activated = "O";
            deactivated = "o";
          };
        };

        tray = {
          spacing = 10;
        };

        clock = {
          "tooltip-format" = "<big>{:%Y %B}</big>";
          "format-alt" = "{:%Y-%m-%d}";
        };

        cpu = {
          format = "{usage}% CPU";
          tooltip = false;
        };

        memory = {
          format = "{used:.1f}/{total:.1f} GB RAM";
        };

        temperature = {
          "critical-threshold" = 80;
          format = "{temperatureC}°C";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          "format-icons" = [ "!" "x" "x" ];
        };

        network = {
          "format-wifi" = "{essid} {signalStrength}%";
          "format-ethernet" = "eth";
          "format-disconnected" = "off";
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
          border-radius: 4px;
          font-family: "Fira Code", monospace;
          font-size: 12px;
      }

      window#waybar {
          color: @text;
          background-color: transparent;
      }

      .modules-left, .modules-center, .modules-right {
          background-color: @base;
          padding: 0 8px;
      }

      #workspaces button {
          padding: 0 4px;
          color: @text;
      }

      #workspaces button.focused {
          color: @blue;
      }

      #clock, #battery, #network, #cpu, #memory, #temperature {
          padding: 0 10px;
          margin: 4px;
      }

      #clock { color: @green; }
      #battery { color: @yellow; }
      #network { color: @blue; }
      #cpu { color: @mauve; }
      #memory { color: @red; }
      #temperature { color: @pink; }
      #tray { background-color: @surface0; }
    '';
  };
}