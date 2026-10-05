{ pkgs, ... }: {
  home.persistence."/persist".directories = [
    ".config/SchildiChatRevenge"
  ];

  home.packages = [ pkgs.schildi-revenge ];
}
