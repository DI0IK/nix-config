{ pkgs, ... }: {
  programs.kitty.enable = true;

  home.persistence."/persist".directories = [
    ".local/share/containers"
  ];
}
