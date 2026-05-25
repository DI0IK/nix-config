{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  # nerd-fonts split into per-family packages — pick the one matching your terminal font
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}