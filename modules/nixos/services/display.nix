{ config, lib, pkgs, ... }:

let
  # Catppuccin Mocha Mauve GTK theme for ReGreet's UI widgets
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "mauve" ];
    size = "standard";
  };
in
{
  # === Greetd + ReGreet ===
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      command = "dbus-run-session ${pkgs.cage}/bin/cage -s -mlast -d -- ${pkgs.regreet}/bin/regreet";
    };
  };

  programs.regreet = {
    enable = true;

    # Catppuccin Mocha Mauve theme for the login widgets
    theme = {
      name = "catppuccin-mocha-mauve-standard";
      package = catppuccinGtk;
    };

    # Clean modern font
    font = {
      package = pkgs.inter;
      name = "Inter";
      size = 15;
    };

    # ReGreet TOML settings — some flair, no greeting text
    settings = {
      greeting = "";
      clock = true;
      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };
    };

    # Custom CSS: Catppuccin background + sleek centered card
    extraCss = ''
      window {
        background-color: #1e1e2e;
      }
      box#main {
        background: rgba(24, 24, 37, 0.85);
        border-radius: 16px;
        padding: 40px 60px;
      }
      entry {
        border-radius: 8px;
        padding: 8px 12px;
        font-size: 15px;
      }
      button {
        border-radius: 8px;
        padding: 8px 16px;
      }
    '';
  };

  users.users.greeter.extraGroups = [ "video" ];

  environment.sessionVariables = {
    UWSM_SILENT_START = "1";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.hyprdynamicmonitors = {
    enable = true;
  };

  services.upower.enable = true;

  security.pam.services.hyprlock = {};
}
