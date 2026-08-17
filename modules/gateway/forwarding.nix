{
  config,
  lib,
  ...
}:

let
  cfg = config.gateway.forwarding;
  addrSet = lib.concatStringsSep ", " cfg.publicAddresses;
in
{
  options.gateway.forwarding = {
    enable = lib.mkEnableOption "forwarding of public traffic to the homelab";

    wanInterface = lib.mkOption {
      type = lib.types.str;
      default = "ens6";
      description = "WAN interface used for NAT/masquerade.";
    };

    publicAddresses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "217.154.87.4" ];
      description = "Public IPv4 addresses accepted for forwarded traffic.";
    };

    homelabAddress = lib.mkOption {
      type = lib.types.str;
      default = "172.30.32.2";
      description = "Tunnel address of the homelab host.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nftables.enable = true;

    networking.nat = {
      enable = true;
      externalInterface = cfg.wanInterface;
      internalInterfaces = [ "wg0" ];
    };

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = lib.mkForce 1;
      "net.ipv6.conf.all.forwarding" = lib.mkForce 1;
      "net.ipv6.conf.default.forwarding" = lib.mkForce 1;
    };

    networking.nftables.tables.gateway-dnat = {
      family = "inet";
      name = "gateway-dnat";
      content = ''
        chain prerouting {
          type nat hook prerouting priority -100; policy accept;
          ip daddr { ${addrSet} } udp dport 1194 dnat to 127.0.0.1:51820
        }
      '';
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
        853
      ];

      extraForwardRules = ''
        ip daddr ${cfg.homelabAddress} tcp dport 853 accept
        iifname "wg0" accept
      '';
    };

    services.haproxy = {
      enable = true;
      config = ''
        global
          log /dev/log local0
          maxconn 4096

        defaults
          log global
          timeout connect 5s
          timeout client 60s
          timeout server 60s

        frontend http_in
          bind *:80
          mode tcp
          default_backend homelab_http

        frontend https_in
          bind *:443
          mode tcp
          default_backend homelab_https

        frontend dns_dot_in
          bind *:853
          mode tcp
          default_backend homelab_dns_dot

        backend homelab_http
          mode tcp
          server homelab ${cfg.homelabAddress}:80 send-proxy-v2

        backend homelab_https
          mode tcp
          server homelab ${cfg.homelabAddress}:443 send-proxy-v2

        backend homelab_dns_dot
          mode tcp
          server homelab ${cfg.homelabAddress}:853 send-proxy-v2
      '';
    };
  };
}
