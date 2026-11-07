{ pkgs, ... }:
let
  wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha.gnomeFilePath}";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = true;
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = wallpaper;
          fit_mode = "cover";
        }
      ];
    };
  };
}
