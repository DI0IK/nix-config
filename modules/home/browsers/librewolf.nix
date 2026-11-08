{
  pkgs,
  lib,
  config,
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
      app.package = pkgs.librewolf;
      flatpak.appId = "io.gitlab.librewolf";

      bubblewrap = {
        network = true;

        bind.rw = [
          (sloth.concat' sloth.homeDir "/.librewolf")
          (sloth.concat' sloth.homeDir "/Downloads")
          (sloth.concat' sloth.homeDir "/.local/share/firefox-mpris")
          (sloth.env "XDG_RUNTIME_DIR")
        ];

        bind.ro = [
          "/run/current-system/sw/share"
          "/tmp/.X11-unix"
          "/etc/ssl/certs"
          "/etc/static/ssl/certs"
          "/etc/machine-id"
          "/etc/localtime"
          "/run/opengl-driver"
          "/sys"
          "/etc/fonts"
          (sloth.concat' sloth.homeDir "/.local/share/fonts")
          (sloth.concat' sloth.homeDir "/.config/fontconfig")
        ];

        bind.dev = [
          "/dev/dri"
          "/dev/shm"
        ];
      };

      dbus.enable = false;
    };
  };
in
{
  home.persistence."/persist".directories = [
    ".librewolf"
  ];

  programs.librewolf = {
    enable = true;
    package = lib.mkForce null;
  };

  home.packages = [ sandboxed.config.env ];
}
