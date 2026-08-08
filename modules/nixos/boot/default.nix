{ ... }: {
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  imports = [
    ./kernel.nix
    ./plymouth.nix
  ];
}
