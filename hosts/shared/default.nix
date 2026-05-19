{ config, pkgs, inputs, ... }: {
  # Global Network & Firewall Hardening
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
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

  boot.blacklistedKernelModules = [
    "ax25"        # Amateur Radio AX.25
    "netrom"      # NetRom routing protocol
    "rose"        # Rose packet radio network
    "firewire-core" # Legacy FireWire controller support
  ];

  # Global Kernel Hardening & Access Control
  boot.kernelParams = [ "page_alloc.shuffle=1" "strict_devmem=1" "iommu=pt" "amd_iommu=on" ];
  security.protectKernelImage = true;
  security.apparmor = {
    enable = true;
    packages = with pkgs; [ apparmor-profiles ];
  };

  # Enforce strict sandboxing profiles for core systemd services
  systemd.package = pkgs.systemd.override {
    withCryptsetup = true;
    # Enables additional underlying service hardening features
    withApparmor = true;
  };

  # Global Identity & Privilege Isolation Policy (Modern run0)
  security.sudo.enable = false;
  security.run0 = {
    enableSudoAlias = true;
    wheelNeedsPassword = true;
  };
  systemd.enableEmergencyMode = false;

  users.users.root = {
    hashedPassword = "!";
  };

  # Global User Management & Secrets Provisioning
  users.users.dominik = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    hashedPasswordFile = config.sops.secrets.dominik-password.path;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.dominik = import ../../home/dominik/default.nix;
    extraSpecialArgs = { inherit inputs; };
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets.dominik-password.neededForUsers = true;
  };
}