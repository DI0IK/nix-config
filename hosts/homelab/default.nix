{ ... }: {
  imports = [
    ./hardware.nix
    ./disk.nix
    ./backup.nix
    ../../modules/homelab
  ];

  networking.hostName = "homelab";

  catppuccin = {
    enable = false;
    autoEnable = false;
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "26.05";
}
