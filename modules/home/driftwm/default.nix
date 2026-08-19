{ pkgs, ... }:

{
  imports = [
    ./config.nix
  ];

  home.packages = with pkgs; [
    pavucontrol
    adwaita-icon-theme
  ];
}
