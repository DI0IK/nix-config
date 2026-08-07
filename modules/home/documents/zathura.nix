{ pkgs, lib, inputs, ... }:

let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  sandboxed = mkNixPak {
    config = { sloth, ... }: {
      app.package = pkgs.zathura;
      flatpak.appId = "org.pwmt.zathura";

      bubblewrap = {
        network = false; # Complete network isolation for security

        bind.rw = [
          (sloth.concat' sloth.homeDir "/.local/share/zathura")
          (sloth.env "XDG_RUNTIME_DIR")
        ];

        bind.ro = [
          "/run/current-system/sw/share"
          "/tmp/.X11-unix"
          (sloth.concat' sloth.homeDir "/Downloads")
          (sloth.concat' sloth.homeDir "/Documents")
        ];

        bind.dev = [
          "/dev/dri"
          "/dev/shm"
        ];
      };

      dbus.enable = true;
      dbus.policies = {
        "org.freedesktop.DBus" = "talk";
        "org.freedesktop.portal.*" = "talk";
        "org.a11y.Bus" = "talk";
      };
    };
  };
in {
  home.persistence."/persist".directories = [
    ".local/share/zathura"
  ];

  home.packages = [ sandboxed.config.env ];
}
