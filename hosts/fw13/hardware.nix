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
    "kvm-amd"
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

    # Bluetooth stack for MT7922
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
    "nft_reject_ipv6"

    # Traffic Control (TC) Quality of Service
    "sch_htb"
    "sch_sfq"
    "cls_u32"
    "act_csum"
    "sch_ingress"
    "act_police"

    # WireGuard VPN
    "wireguard"

    # Framework 13 & ChromeOS EC controls
    "framework_laptop"
    "cros_ec_lpcs"
    "cros_ec_dev"
    "cros_ec_sysfs"
    "cros_charge_control"
    "cros_kbd_led_backlight"
    "gpio_cros_ec"

    # AMD SoC Platform, Power Management & Hardware Monitoring
    "k10temp"
    "amd_pmf"
    "amd_pmc"
    "amd_sfh"
    "amdtee"
    "amdxcp"
    "amdxdna"
    "spd5118"
    "sp5100_tco"

    # Sound & Audio Subsystem (Built-in ALC269, HDMI & external USB audio devices)
    "snd_hda_codec_alc269"
    "snd_hda_codec_hdmi"
    "snd_hda_intel"
    "snd_sof_amd_rembrandt"
    "snd_usb_audio"

    # USB Type-C, Thunderbolt & Hotplug Network Adapters
    "thunderbolt"
    "typec"
    "typec_ucsi"
    "ucsi_acpi"
    "r8152"
    "cdc_ether"

    # Input, Touchpad & Ambient Light Sensor
    "hid_sensor_hub"
    "hid_sensor_als"
    "hid_multitouch"
    "i2c_hid_acpi"

    # Storage & Filesystems
    "usb_storage"
    "uas"
    "nvme"
    "ahci"
    "sd_mod"
    "ext4"
    "btrfs"
    "vfat"
    "exfat"
    "ntfs3"
    "dm_crypt"
    "dm_mod"
    "fuse"
    "cifs"
    "nfs"

    # USB-Serial Adapters
    "cp210x"
    "ch341"
    "ftdi_sio"
    "pl2303"
    "cdc_acm"
    "usbserial"
  ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.initrd.luks.devices.crypted.device =
    lib.mkForce "/dev/disk/by-uuid/1ae46ce0-719c-412e-991b-9fec7ddb1183";
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-uuid/0DD7-2C90";
}
