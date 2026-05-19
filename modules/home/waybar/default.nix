{ config, lib, pkgs, ... }:

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
      /* Catppuccin Mocha Color Palette Definitions */
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;
      @define-color text #cdd6f4;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color overlay0 #6c7086;
      @define-color red #f38ba8;
      @define-color pink #f5c2e7;
      @define-color mauve #cba6f7;
      @define-color blue #89b4fa;
      @define-color sapphire #74c7ec;
      @define-color cyan #89dceb;
      @define-color teal #94e2d5;
      @define-color green #a6e3a1;
      @define-color yellow #f9e2af;
      @define-color peach #fab387;
      @define-color maroon #eba0ac;

      /* Core Style Sheets */
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