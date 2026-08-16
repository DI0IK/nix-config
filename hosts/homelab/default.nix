{ ... }: {
  imports = [
    ./hardware.nix
    ./disk.nix
    ./backup.nix
    ../../modules/nixos/services/dns.nix
    ../../modules/homelab
  ];

  networking.hostName = "homelab";
  networking.dnsOverTls = "1.1.1.1#one.one.one.one";

  catppuccin = {
    enable = false;
    autoEnable = false;
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "26.05";
}
