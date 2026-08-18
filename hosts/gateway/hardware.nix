{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    # VirtIO / QEMU disk and PCI support
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"

    # Common block device support
    "sd_mod"
    "sr_mod"
  ];

  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [
    # NAT and forwarding support for the wireguard gateway
    "nf_nat"
    "nft_nat"
    "nft_chain_nat"
    "nft_masq"
    "nf_conntrack"
    "nft_ct"
  ];

  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
