{ pkgs, ... }: {
  imports = [
    ../../modules/home
  ];

  home.persistence."/persist" = {
    directories = [
      ".librewolf"
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "projects"

      ".gnupg"
      ".config/Signal"
      ".thunderbird"
      ".config/VSCodium"
      ".vscode-oss"
      ".local/share/containers"
      ".config/darktable"
      ".local/share/darktable"
      ".local/share/zathura"
      ".local/share/direnv"
      ".config/libreoffice"
      ".config/mpv"
      ".config/hyprdynamicmonitors"
      ".cache/borg"
      ".kube"
      ".config/sops"
    ];

    files = [
      ".zsh_history"
    ];
  };
}
