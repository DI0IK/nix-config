{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ 
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "sd_mod"
    "atkbd"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "bridge" "tun" "tap" "kvm-amd" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.luks.devices.crypted.device = lib.mkForce "/dev/disk/by-uuid/1ae46ce0-719c-412e-991b-9fec7ddb1183";
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-uuid/0DD7-2C90";
}
