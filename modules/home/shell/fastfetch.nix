{ ... }: {
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "builtin";
        source = "nixos_small";
        padding = {
          top = 1;
          left = 2;
          right = 4;
        };
      };
      display = {
        separator = " 󰄾 ";
        color = {
          keys = "magenta";
          title = "blue";
        };
      };
      modules = [
        "title"
        {
          type = "separator";
          string = "─";
        }
        {
          type = "os";
          key = "󱄅 OS";
          keyColor = "cyan";
        }
        {
          type = "host";
          key = "󰌢 Host";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "󰌽 Kernel";
          keyColor = "yellow";
        }
        {
          type = "uptime";
          key = "󱑂 Uptime";
          keyColor = "green";
        }
        {
          type = "packages";
          key = "󰏗 Packages";
          keyColor = "magenta";
        }
        {
          type = "shell";
          key = "󰞷 Shell";
          keyColor = "red";
        }
        {
          type = "wm";
          key = "󱂬 WM";
          keyColor = "magenta";
        }
        {
          type = "terminal";
          key = "󰆍 Terminal";
          keyColor = "blue";
        }
        {
          type = "cpu";
          key = "󰻠 CPU";
          keyColor = "cyan";
        }
        {
          type = "gpu";
          key = "󰢮 GPU";
          keyColor = "cyan";
        }
        {
          type = "memory";
          key = "󰍛 Memory";
          keyColor = "magenta";
        }
        {
          type = "battery";
          key = "󰂄 Battery";
          keyColor = "green";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };
}
