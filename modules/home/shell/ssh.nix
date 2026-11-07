{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      # Homelab (VPN - default)
      "homelab homelab-vpn" = {
        hostname = "172.30.32.2";
        user = "root";
      };

      # Homelab (local network)
      "homelab-local" = {
        hostname = "192.168.178.110";
        user = "root";
      };

      # VPS
      "vps" = {
        hostname = "217.154.87.4";
        port = 2222;
        user = "root";
      };
    };
  };

  home.persistence."/persist" = {
    directories = [
      {
        directory = ".ssh";
        mode = "0700";
      }
    ];
  };
}
