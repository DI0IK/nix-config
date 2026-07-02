{ config, pkgs, ... }:

{
  # Enable libvirtd daemon
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
    };
    firewallBackend = "nftables";
  };

  # Install virt-manager (the GUI)
  environment.systemPackages = with pkgs; [
    virt-manager
  ];

  # Manage nested virtualization or specific spice protocols (Optional but recommended)
  virtualisation.spiceUSBRedirection.enable = true;
}
