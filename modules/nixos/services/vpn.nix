{ config, ... }: {
  sops.secrets.wg-private-key = { };

  networking.wg-quick.interfaces.wg0 = {
    autostart = true;
    address = [
      "172.30.32.20/32"
      "fd86:ea04:1115::20/128"
    ];
    mtu = 1280;
    privateKeyFile = config.sops.secrets.wg-private-key.path;

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
