{ ... }: {
  boot.loader.systemd-boot.configurationLimit = 10;

  imports = [
    ./kernel.nix
    ./secure-boot.nix
    ./plymouth.nix
  ];
}