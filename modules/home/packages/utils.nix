{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    btop
    yazi
    wl-clipboard

    # GUI Applications
    vscodium-fhs
    libreoffice-fresh
    mpv
    darktable

    # Utilities
    brightnessctl
    playerctl
  ];
}