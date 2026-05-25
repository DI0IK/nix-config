{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    btop
    yazi
    wl-clipboard

    # Utilities
    brightnessctl
    playerctl
  ];
}