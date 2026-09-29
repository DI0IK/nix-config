{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

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
    "veth"

    # v4 and v6 address support
    "af_packet"
    
    # Full MediaTek Wi-Fi stack
    "mt7921e"
    "mt7921_common"
    "mt792x_lib"
    "mt76_connac_lib"
    "mt76"
    "mac80211"
    "cfg80211"
    "rfkill"

    # Bluetooth stack for MT7922 (prevents coexistence driver issues)
    "btmtk"
    "btusb"
    "bluetooth"

    # Cryptographic ciphers for WPA2 / WPA3 (SAE) negotiation
    "ccm"
    "ctr"
    "gcm"
    "cmac"
    "ecb"
    "arc4"
    "libarc4"
    "ecc"
    "ecdh_generic"
    "crypto_simd"

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
    "sch_ingress" # Future-proofing for VM network throttling
    "act_police" # Future-proofing for VM network throttling

    "usb_storage"
    "uas"
    "sd_mod"
    "btusb"

    "nvme"
    "ahci"
    "sd_mod"
    "ext4"
    "btrfs"
    "exfat"
    "ntfs3"
    "dm_crypt"
    "dm_mod"
    "fuse"

    "cifs"
    "nfs"
  ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.luks.devices.crypted.device =
    lib.mkForce "/dev/disk/by-uuid/1ae46ce0-719c-412e-991b-9fec7ddb1183";
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-uuid/0DD7-2C90";
}
