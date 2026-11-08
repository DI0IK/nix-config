{
  config,
  lib,
  pkgs,
  ...
}:

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
      command = lib.concatStringsSep " " [
        "env GTK_USE_PORTAL=0 GDK_DEBUG=no-portals GSK_RENDERER=gl XDG_CACHE_HOME=/tmp/greeter-cache"
        "dbus-run-session"
        "${pkgs.cage}/bin/cage -s -mlast -d --"
        "${pkgs.regreet}/bin/regreet"
      ];
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/greetd"
  ];

  services.displayManager.regreet = {
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
        reboot = [
          "systemctl"
          "reboot"
        ];
        poweroff = [
          "systemctl"
          "poweroff"
        ];
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

  users.users.greeter.extraGroups = [
    "video"
    "render"
  ];

  # Dual Auth: Password first (with GNOME Keyring capture), fallback to Fingerprint on empty Enter.
  security.pam.services.greetd.rules.auth = lib.mkForce {
    "10_unix_early" = {
      order = 11700;
      control = "optional";
      modulePath = "${pkgs.pam}/lib/security/pam_unix.so";
      args = [
        "likeauth"
        "nullok"
      ];
    };
    "20_gnome_keyring" = {
      order = 12200;
      control = "optional";
      modulePath = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";
    };
    "30_unix" = {
      order = 13100;
      control = "sufficient";
      modulePath = "${pkgs.pam}/lib/security/pam_unix.so";
      args = [
        "likeauth"
        "nullok"
        "try_first_pass"
      ];
    };
    "40_fprintd" = {
      order = 13500;
      control = "sufficient";
      modulePath = "${config.services.fprintd.package}/lib/security/pam_fprintd.so";
    };
    "50_deny" = {
      order = 13900;
      control = "required";
      modulePath = "${pkgs.pam}/lib/security/pam_deny.so";
    };
  };

  environment.sessionVariables = {
    UWSM_SILENT_START = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    JAVA_TOOL_OPTIONS = "-Dawt.toolkit.name=WLToolkit";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.driftwm.enable = true;

  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  services.upower.enable = true;
}
