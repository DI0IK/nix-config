{ ... }: {
  imports = [
    ./base.nix
    ./shells/zsh.nix
    ./packages
    ./hyprland
    ./waybar
    ./mako
    ./fuzzel
    ./direnv
    ./librewolf
  ];
}