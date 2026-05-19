{ config, lib, ... }:

{
  security.sudo.enable = false;

  security.run0 = {
    enableSudoAlias = true;
    wheelNeedsPassword = true;
  };

  systemd.enableEmergencyMode = false;
}