{ ... }: {
  # Only keep the last 10 generations in the systemd-boot menu
  boot.loader.systemd-boot.configurationLimit = 10;

  imports = [
    ./kernel.nix
    ./secure-boot.nix
    ./plymouth.nix
  ];
}