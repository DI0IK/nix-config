{ ... }: {
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    sortKey = "01-nixos";
  };

  imports = [
    ./kernel.nix
    ./plymouth.nix
  ];
}
