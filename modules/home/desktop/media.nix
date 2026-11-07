{ pkgs, ... }: {
  home.packages = with pkgs; [
    loupe # Clean Wayland image viewer
    nautilus # Lightweight GUI file manager for drag-and-drop & previews
    file-roller # Archive manager
  ];
}
