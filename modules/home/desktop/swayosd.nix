{ pkgs, ... }: {
  services.swayosd = {
    enable = true;
    package = pkgs.swayosd;
  };

  home.packages = with pkgs; [
    swayosd
  ];

  # Catppuccin Mocha styling for SwayOSD
  xdg.configFile."swayosd/style.css".text = ''
    window {
      background: rgba(30, 30, 46, 0.92);
      border-radius: 14px;
      border: 2px solid #cba6f7;
      padding: 12px;
    }

    progressbar:disabled,
    image:disabled {
      opacity: 0.5;
    }

    progressbar {
      min-height: 6px;
      border-radius: 999px;
      background: rgba(69, 71, 90, 0.6);
      border: none;
    }

    trough {
      min-height: 6px;
      border-radius: 999px;
      background: rgba(69, 71, 90, 0.6);
      border: none;
    }

    progress {
      min-height: 6px;
      border-radius: 999px;
      background: #cba6f7;
      border: none;
    }

    label {
      font-family: "JetBrainsMono Nerd Font Propo", "JetBrainsMono Nerd Font", monospace;
      font-size: 13px;
      color: #cdd6f4;
    }

    image {
      color: #cba6f7;
    }
  '';
}
