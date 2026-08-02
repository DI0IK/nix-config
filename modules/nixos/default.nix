{ ... }: {
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "mauve";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  _module.args.theme = import ../home/theme.nix;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Berlin";

  imports = [
    ./boot
    ./security
    ./services
    ./users/users.nix
    ./impermanence.nix
  ];
}
