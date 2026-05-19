{ config, lib, ... }:

{
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
}