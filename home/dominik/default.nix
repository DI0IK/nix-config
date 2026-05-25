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
    ];

    files = [
      ".zsh_history"
    ];
  };
}