{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    btop

    hyprpolkitagent
    pavucontrol
    yazi
    wl-clipboard

    # Utilities
    brightnessctl
    playerctl
  ];
}