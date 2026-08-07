{ pkgs, ... }: {
  imports = [
    ./common.nix
    ../../modules/home/browsers/librewolf.nix
    ../../modules/home/communication/signal.nix
    ../../modules/home/communication/thunderbird.nix
    ../../modules/home/desktop/fuzzel.nix
    ../../modules/home/desktop/kitty.nix
    ../../modules/home/desktop/mako.nix
    ../../modules/home/desktop/theme.nix
    ../../modules/home/desktop/udiskie.nix
    ../../modules/home/desktop/waybar.nix
    ../../modules/home/development/neovim.nix
    ../../modules/home/development/vscode.nix
    ../../modules/home/hyprland
    ../../modules/home/shell/direnv.nix
  ];

  home.persistence."/persist" = {
    directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Videos"

      "projects"

      ".gradle"
      ".gnupg"
      ".config/darktable"
      ".config/JetBrains"
      ".local/share/JetBrains"
      ".cache/JetBrains"
      ".local/share/darktable"
      ".local/share/zathura"
      ".config/libreoffice"
      ".config/mpv"
      ".kube"
    ];

    files = [
      ".zsh_history"
    ];
  };

  home.packages = with pkgs; [
    wl-clipboard
    antigravity-fhs
    libreoffice-fresh
    mpv
    darktable
    jetbrains.idea
    opencode
    cura-appimage
    brightnessctl
    playerctl
    age-plugin-yubikey
  ];
}