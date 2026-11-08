{
  pkgs,
  lib,
  theme ? import ../../shared/theme.nix,
  ...
}:

let
  strip = lib.removePrefix "#";
  mauveHex = strip theme.mauve;

  setCatppuccinRgb = pkgs.writeShellScriptBin "set-catppuccin-rgb" ''
    set -u
    COLOR="''${1:-${mauveHex}}"

    # Try applying via openrgb (retrying up to 5 times if daemon is starting)
    for i in $(seq 1 5); do
      if ${pkgs.openrgb}/bin/openrgb --mode static --color "$COLOR" 2>/dev/null; then
        echo "Successfully applied RGB color #$COLOR"
        exit 0
      fi
      sleep 1
    done

    echo "Failed to apply RGB color #$COLOR to devices" >&2
    exit 1
  '';
in
{
  home.packages = with pkgs; [
    openrgb
    setCatppuccinRgb
  ];

  # Apply color automatically on graphical session startup
  systemd.user.services.catppuccin-rgb = {
    Unit = {
      Description = "Apply Catppuccin RGB lighting to connected peripherals";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${setCatppuccinRgb}/bin/set-catppuccin-rgb";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
