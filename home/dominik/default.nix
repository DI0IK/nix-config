{ pkgs, ... }: {
  imports = [
    ../../modules/home
  ];

  home.persistence."/persist/home" = {
    directories = [
      ".librewolf"
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "projects"

      ".config/Signal"
      ".thunderbird"
      ".config/VSCodium"
      ".vscode-oss"
      ".local/share/containers"
      ".config/darktable"
      ".local/share/darktable"
      ".local/share/zathura"
      ".config/libreoffice"
      ".config/mpv"
    ];

    files = [
      ".zsh_history"
    ];
  };
}