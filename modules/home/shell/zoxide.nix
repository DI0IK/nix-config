{ ... }:

{
  programs.zoxide.enable = true;

  home.persistence."/persist".directories = [
    ".local/share/zoxide"
  ];
}