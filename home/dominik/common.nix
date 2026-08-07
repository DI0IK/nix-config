{ pkgs, ... }: {
  imports = [
    ../../modules/home/development/git.nix
    ../../modules/home/shell/zoxide.nix
    ../../modules/home/shell/zsh.nix
    ../../modules/home/fonts.nix
  ];

  home.persistence."/persist" = {
    directories = [
      ".cache/borg"
      ".config/sops"
    ];

    files = [
      ".zsh_history"
    ];
  };

  home.packages = with pkgs; [
    btop
    yazi
    sops
  ];
}
