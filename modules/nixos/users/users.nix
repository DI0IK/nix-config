{ config, ... }:

{
  users.users.dominik = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.dominik-password.path;
  };
}