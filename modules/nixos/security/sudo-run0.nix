{ config, lib, ... }:

{
  security.sudo.enable = false;

  security.run0 = {
    enableSudoAlias = false;
    wheelNeedsPassword = true;
  };

  systemd.enableEmergencyMode = false;
}
