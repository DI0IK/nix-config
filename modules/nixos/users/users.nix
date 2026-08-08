{ config, pkgs, ... }:

{
  programs.zsh.enable = true;

  users.users.dominik = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.dominik-password.path;
  };

  environment.systemPackages = with pkgs; [
    kitty.terminfo
  ];
}
