{ pkgs, ... }: {
  home.username = "dominik";
  home.homeDirectory = "/home/dominik";

  home.stateVersion = "26.05"; 

  home.packages = with pkgs; [
    git
    htop
  ];
}