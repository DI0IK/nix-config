{ pkgs, ... }: {
  imports = [
    ../../modules/home
  ];

  home.persistence."/persist" = {
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"
      "projects"
    ];

    files = [
      ".zsh_history"
    ];
  };
}