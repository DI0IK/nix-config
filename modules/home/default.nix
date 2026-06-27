{ ... }: {
  imports = [
    ./base.nix
    ./shells/zsh.nix
    ./packages
    ./hyprland
    ./kitty
    ./waybar
    ./mako
    ./fuzzel
    ./direnv
    ./librewolf
    ./thunderbird
    ./signal
    ./zathura
  ];
}