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

  programs.git = {
    enable = true;
    userName = "Dominik Stahl";
    userEmail = "dominik@samdj.de";

    signing = {
      key = null;
      signByDefault = true; 
    };
  };
}
