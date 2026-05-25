{ config, lib, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.ip_forward" = 0;
    "net.ipv4.tcp_syncookies" = 1;
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
  };

  boot.kernelParams = [
    "page_alloc.shuffle=1"
    "strict_devmem=1"
    "iommu=pt"
    "amd_iommu=on"
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "init_on_alloc=1"
    "init_on_free=1"
    "slab_nomerge"
    "randomize_kstack_offset=on"
  ];

  boot.blacklistedKernelModules = [
    "ax25"
    "netrom"
    "rose"
    "firewire-core"
  ];

}