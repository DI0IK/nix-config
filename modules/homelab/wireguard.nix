{ config, lib, ... }:

let
  cfg = config.homelab.wireguard;
in
{
  options.homelab.wireguard = {
    enable = lib.mkEnableOption "inbound-only VPS wireguard tunnel";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."homelab-wg-private-key" = { };

    networking.wg-quick.interfaces.wg0 = {
      autostart = true;
      address = [
        "172.30.32.2/24"
        "fd86:ea04:1115::2/128"
      ];
      mtu = 1350;
      privateKeyFile = config.sops.secrets."homelab-wg-private-key".path;
      peers = [
        {
          publicKey = "xp2zUi4Dx1wSQwZq3mKL7RwOIKFc9G12LyzinAj/8C4=";
          endpoint = "217.154.87.4:51820";
          allowedIPs = [
            "172.30.32.1/24"
            "fd86:ea04:1115::1/128"
          ];
          persistentKeepalive = 20;
        }
      ];
    };

    networking.firewall = {
      # traefik entrypoints, reachable via tunnel (wg0) + LAN for pre-cutover testing
      allowedTCPPorts = [ 80 443 853 2222 1883 ];
      allowedUDPPorts = [ 443 ];
    };
  };
}
