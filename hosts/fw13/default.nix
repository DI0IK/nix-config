{ config, pkgs, inputs, ... }: {
  imports = [
    ../../modules/nixos
    ./hardware.nix
    ./disk.nix
  ];

  networking.hostName = "fw13";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.fuse.userAllowOther = true;

  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets.dominik-password.neededForUsers = true;
  };

  system.stateVersion = "26.05";
}