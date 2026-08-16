{
  config,
  lib,
  ...
}:

let
  cfg = config.gateway.wireguard;
in
{
  options.gateway.wireguard = {
    enable = lib.mkEnableOption "wireguard hub";

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = "UDP port the wireguard hub listens on.";
    };

    address = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "172.30.32.1/24"
        "fd86:ea04:1115::1/128"
      ];
      description = "Tunnel addresses of the hub.";
    };

    peers = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Descriptive name of the peer.";
            };
            publicKey = lib.mkOption {
              type = lib.types.str;
              description = "WireGuard public key of the peer.";
            };
            allowedIPs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Tunnel addresses belonging to the peer.";
            };
          };
        }
      );
      default = [ ];
      description = "WireGuard peers reachable through the hub.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.wg-private-key = { };

    networking.wg-quick.interfaces.wg0 = {
      autostart = true;
      inherit (cfg) address listenPort;
      mtu = 1350;
      privateKeyFile = config.sops.secrets.wg-private-key.path;

      peers = map (peer: {
        publicKey = peer.publicKey;
        allowedIPs = peer.allowedIPs;
      }) cfg.peers;
    };

    networking.firewall.allowedUDPPorts = [ cfg.listenPort ];
  };
}
