{ ... }: {
  boot.loader.systemd-boot.configurationLimit = 10;

  imports = [
    ./kernel.nix
    ./plymouth.nix
  ];
}