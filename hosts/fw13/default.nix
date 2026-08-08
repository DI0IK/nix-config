{ ... }: {
  imports = [
    ./hardware.nix
    ./disk.nix
    ./backup.nix
    ../../modules/nixos/services/audio.nix
    ../../modules/nixos/services/automount.nix
    ../../modules/nixos/services/bluetooth.nix
    ../../modules/nixos/services/containers.nix
    ../../modules/nixos/services/display.nix
    ../../modules/nixos/services/dns.nix
    ../../modules/nixos/services/gpg.nix
    ../../modules/nixos/services/smartcards.nix
    ../../modules/nixos/services/snapshots.nix
    ../../modules/nixos/services/virt.nix
    ../../modules/nixos/services/vpn.nix
    ../../modules/nixos/theme.nix

    ../../modules/nixos/boot/secure-boot.nix
  ];

  networking.hostName = "fw13";

  programs.fuse.userAllowOther = true;

  system.stateVersion = "26.05";
}
