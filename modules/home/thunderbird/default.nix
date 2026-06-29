{ pkgs, lib, inputs, ... }:

let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  sandboxed = mkNixPak {
    config = { sloth, ... }: {
      app.package = pkgs.thunderbird;
      flatpak.appId = "org.mozilla.Thunderbird";

      bubblewrap = {
        network = true;

        bind.rw = [
          (sloth.concat' sloth.homeDir "/.thunderbird")
          (sloth.env "XDG_RUNTIME_DIR")
        ];

        bind.ro = [
          "/run/current-system/sw/share"
          "/tmp/.X11-unix"
          "/etc/ssl/certs"
          "/etc/static/ssl/certs"
          "/etc/machine-id"
          "/etc/localtime"
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
  programs.thunderbird = {
    enable = true;
    package = sandboxed.config.env;
  };
}
