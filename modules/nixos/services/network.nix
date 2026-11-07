{ ... }:

{
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";

    ensureProfiles.profiles = {
      "home-ethernet" = {
        connection = {
          id = "home-ethernet";
          type = "ethernet";
          interface-name = "enp195s0f3u1u3";
          autoconnect = true;
          dns-over-tls = 0;
        };
        ipv4 = {
          method = "auto";
          dns = "192.168.178.110;";
          ignore-auto-dns = true;
          dns-priority = -50;
          dns-search = "~.;";
        };
        ipv6 = {
          method = "auto";
        };
      };
    };
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
