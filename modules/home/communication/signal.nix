{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  sandboxed = mkNixPak {
    config = { sloth, ... }: {
      app.package = pkgs.signal-desktop;
      flatpak.appId = "org.signal.Signal";

      bubblewrap = {
        network = true;

        bind.rw = [
          (sloth.concat' sloth.homeDir "/.config/Signal")
          (sloth.env "XDG_RUNTIME_DIR")
        ];

        bind.ro = [
          "/run/current-system/sw/share"
          "/tmp/.X11-unix"
          "/etc/fonts"
          (sloth.concat' sloth.homeDir "/.local/share/fonts")
          (sloth.concat' sloth.homeDir "/.config/fontconfig")
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
in
{
  home.persistence."/persist".directories = [
    ".config/Signal"
  ];

  home.packages = [ sandboxed.config.env ];
}
