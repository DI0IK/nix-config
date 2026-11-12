{ pkgs, ... }: {
  imports = [
    ./common.nix
    ../../modules/home/browsers/librewolf.nix
    ../../modules/home/communication/schildi-revenge.nix
    ../../modules/home/communication/signal.nix
    ../../modules/home/communication/thunderbird.nix
    ../../modules/home/desktop/fuzzel.nix
    ../../modules/home/desktop/fuzzel-tools.nix
    ../../modules/home/desktop/clipboard.nix
    ../../modules/home/desktop/gtk.nix
    ../../modules/home/desktop/kitty.nix
    ../../modules/home/desktop/swaync.nix
    ../../modules/home/desktop/swayosd.nix
    ../../modules/home/desktop/hyprsunset.nix
    ../../modules/home/desktop/media.nix
    ../../modules/home/desktop/feishin.nix
    ../../modules/home/desktop/rgb.nix
    ../../modules/home/desktop/udiskie.nix
    ../../modules/home/desktop/waybar.nix
    ../../modules/home/shell/starship.nix
    ../../modules/home/development/neovim.nix
    ../../modules/home/development/vscode.nix
    ../../modules/home/development/zed.nix
    ../../modules/home/development/antigravity-ide.nix
    ../../modules/home/development/antigravity.nix
    ../../modules/home/documents/zathura.nix
    ../../modules/home/hyprland
    ../../modules/home/driftwm
    ../../modules/home/gaming/steam.nix
    ../../modules/home/gaming/prismlauncher.nix
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
      ".config/libreoffice"
      ".config/mpv"
      ".config/Antigravity IDE"
      ".antigravity-ide"
      ".config/Antigravity"
      ".gemini"
      ".kube"
      ".ollama"
      ".config/opencode"
      ".local/share/opencode"
      ".local/state/opencode"
      ".dsh"
      ".config/zed"
      ".local/share/zed"
    ];

  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.mochaMauve;
    name = "catppuccin-mocha-mauve-cursors";
    size = 24;
  };

  home.packages = with pkgs; [
    catppuccin-cursors.mochaMauve
    wl-clipboard
    libreoffice-stable
    ollama
    mpv
    darktable
    jetbrains.idea
    opencode
    deepseek-harness
    cura-appimage
    age-plugin-yubikey
    devenv
  ];
}
