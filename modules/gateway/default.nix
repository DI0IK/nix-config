{ ... }:
{
  imports = [
    ./forwarding.nix
    ./gatus.nix
    ./wireguard.nix
  ];

  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "172.30.32.1";
    openFirewall = false;
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 9100 ];
}
