{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ../shared/default.nix
    ../../modules/system/default.nix
  ];

  networking.hostName = "fw13";

  # lanzaboot instead of GRUB for UEFI booting, with secure settings
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/persist/etc/secureboot";
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      autoReboot = true; 
    };
  };

  # latest stable Linux kernel for better hardware support, especially for newer devices
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # persist directory for storing all user data
  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "26.05";
}