{ config, ... }:

{
  sops.secrets.wg-private-key = { };

  networking.wg-quick.interfaces.wg0 = {
    autostart = true;
    address = [
      "172.30.32.20/32"
      "fd86:ea04:1115::20/128"
    ];
    mtu = 1280;
    privateKeyFile = config.sops.secrets.wg-private-key.path;

    # Exclude internal / private subnets and multicast from the VPN tunnel.
    # Rules with priority 100 are evaluated before wg-quick's routing table (table 51820),
    # ensuring local Wi-Fi, campus LAN (10.0.0.0/8, 192.168.0.0/16), and mDNS (224.0.0.0/4)
    # are routed directly through the physical network interface.
    postUp = ''
      ip rule add to 10.0.0.0/8 table main priority 100
      ip rule add to 192.168.0.0/16 table main priority 100
      ip rule add to 224.0.0.0/4 table main priority 100
    '';

    postDown = ''
      ip rule del to 10.0.0.0/8 table main priority 100 || true
      ip rule del to 192.168.0.0/16 table main priority 100 || true
      ip rule del to 224.0.0.0/4 table main priority 100 || true
    '';

    peers = [
      {
        publicKey = "xp2zUi4Dx1wSQwZq3mKL7RwOIKFc9G12LyzinAj/8C4=";
        endpoint = "217.154.87.4:1194";
        allowedIPs = [
          "0.0.0.0/0"
          "::0/0"
        ];
        persistentKeepalive = 25;
      }
    ];
  };
}
