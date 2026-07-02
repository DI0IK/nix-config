{ pkgs, lib, config, inputs, ... }:

let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  sandboxed = mkNixPak {
    config = { sloth, ... }: {
      app.package = pkgs.librewolf;
      flatpak.appId = "io.gitlab.librewolf";

      bubblewrap = {
        network = true;

        bind.rw = [
          (sloth.concat' sloth.homeDir "/.librewolf")
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
        "org.mozilla.*" = "own";
      };
    };
  };
in {
  programs.librewolf = {
    enable = true;
    package = lib.mkForce null;
  };

  home.packages = [ sandboxed.config.env ];
}
