{ ... }: {
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  _module.args.theme = import ../home/theme.nix;

  time.timeZone = "Europe/Berlin";

  imports = [
    ./boot
    ./security
    ./services
    ./users/users.nix
    ./impermanence.nix
  ];
}
