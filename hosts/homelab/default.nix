{ ... }: {
  imports = [
    ./hardware.nix
    ./disk.nix
    ./backup.nix
  ];

  networking.hostName = "homelab";

  services.qemuGuest.enable = true;

  system.stateVersion = "26.05";
}
