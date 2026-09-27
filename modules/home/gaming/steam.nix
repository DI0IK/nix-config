{ pkgs, ... }:

{
  home.persistence."/persist" = {
    directories = [
      ".local/share/Steam"
      ".steam"
    ];
  };

  home.packages = with pkgs; [
    mangohud
  ];
}
