{ pkgs, ... }: {
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/development/git.nix
    ../../modules/home/shell/zoxide.nix
    ../../modules/home/shell/zsh.nix
    ../../modules/home/fonts.nix
  ];

  home.persistence."/persist" = {
    directories = [
      ".cache/borg"
      ".config/sops"
      ".local/share/containers"
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
