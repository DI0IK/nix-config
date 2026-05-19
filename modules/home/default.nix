{ ... }: {
  imports = [
    ./base.nix
    ./shells
    ./packages
    ./hyprland
    ./waybar
    ./mako
    ./fuzzel
  ];
}