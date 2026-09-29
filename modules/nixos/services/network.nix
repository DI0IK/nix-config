{ config, pkg, ... }:

{
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };

  environment.persistence."/persist".directories = [
    "/etc/NetworkManager/system-connections"
    "/var/lib/NetworkManager"
    "/var/lib/iwd"
  ];
}
