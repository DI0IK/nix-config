{ pkgs, lib, ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$battery"
        "$line_break"
        "$character"
      ];

      character = {
        success_symbol = "[❯](bold #cba6f7)";
        error_symbol = "[❯](bold #f38ba8)";
      };

      directory = {
        style = "bold #89b4fa";
        truncation_length = 4;
        truncate_to_repo = true;
        read_only = " 󰌾";
      };

      git_branch = {
        symbol = " ";
        style = "bold #f5c2e7";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold #f38ba8";
        format = "([$all_status$ahead_behind]($style) )";
      };

      nix_shell = {
        symbol = "❄️ ";
        style = "bold #89dceb";
        format = "via [$symbol$name]($style) ";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold #f9e2af";
        format = "took [$duration]($style) ";
      };

      battery = {
        full_symbol = "󰁹 ";
        charging_symbol = "󰂄 ";
        discharging_symbol = "󰂃 ";
        display = [
          {
            threshold = 30;
            style = "bold #fab387";
          }
          {
            threshold = 15;
            style = "bold #f38ba8";
          }
        ];
      };
    };
  };
}
