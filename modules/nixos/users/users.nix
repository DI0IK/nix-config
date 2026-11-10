{ config, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.users.dominik = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "podman"
      "video"
      "camera"
      "libvirtd"
      "kvm"
    ];
    hashedPasswordFile = config.sops.secrets.dominik-password.path;
  };

  environment.systemPackages = with pkgs; [
    kitty.terminfo
  ];
}
