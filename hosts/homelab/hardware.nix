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
    # Usually not needed explicitly.
    # Add only if you run nested virtualization inside this VM:
    # "kvm-amd"
    # "kvm-intel"
  ];

  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
