{ ... }: {
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Berlin";

  imports = [
    ./boot
    ./security
    ./sops.nix
    ./users/users.nix
    ./impermanence.nix
  ];
}
