{ pkgs, ... }: {
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/development/git.nix
    ../../modules/home/development/tools.nix
    ../../modules/home/shell/ssh.nix
    ../../modules/home/shell/zoxide.nix
    ../../modules/home/shell/zsh.nix
    ../../modules/home/shell/fastfetch.nix
    ../../modules/home/fonts.nix
  ];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";

    # Thunderbird runs sandboxed via nixpak without HM profiles
    thunderbird.enable = false;
  };

  programs.btop.enable = true;
  programs.yazi.enable = true;

  home.file.".face".source = ./face.png;
  home.file.".face.icon".source = ./face.png;

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
    sops
  ];
}
