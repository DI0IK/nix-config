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
  boot.kernelModules = [ 
    # KVM & Core Virtualization
    "kvm-amd" # (or kvm-intel if you change CPUs)
    "bridge"
    "tun"
    "tap"

    # Native NFTables Translation Engine
    "nf_nat"
    "nft_nat"
    "nft_chain_nat"
    "nft_masq"

    # Stateful Inspection & Rejection
    "nf_conntrack"
    "nft_ct"
    "nft_reject"
    "nft_reject_ipv4"
    "nft_reject_ipv6" # Future-proofing for IPv6

    # Traffic Control (TC) Quality of Service & DHCP Fixes
    "sch_htb"
    "sch_sfq"
    "cls_u32"
    "act_csum"
    "sch_ingress"     # Future-proofing for VM network throttling
    "act_police"      # Future-proofing for VM network throttling
  ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.luks.devices.crypted.device = lib.mkForce "/dev/disk/by-uuid/1ae46ce0-719c-412e-991b-9fec7ddb1183";
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-uuid/0DD7-2C90";
}
