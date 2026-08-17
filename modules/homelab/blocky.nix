{ config, lib, ... }:

let
  cfg = config.homelab.blocky;
  certPath = "/var/lib/acme/dominikstahl";
in
{
  options.homelab.blocky = {
    enable = lib.mkEnableOption "Blocky DNS server (DoT + ad-blocking)";
  };

  config = lib.mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports = {
          tls = 853;
          http = 4000;
          proxyProtocol = [ "tls" ];
        };

        certFile = "${certPath}/fullchain.pem";
        keyFile = "${certPath}/key.pem";

        upstreams.groups.default = [
          "tcp-tls:dns.digitale-gesellschaft.ch:853"
          "tcp-tls:dns3.digitalcourage.de:853"
          "tcp-tls:dot.sb:853"
        ];
        upstreams.strategy = "parallel_best";
        upstreams.timeout = "2s";

        blocking = {
          denylists.ads = [
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
          ];
          clientGroupsBlock.default = [ "ads" ];
          blockType = "zeroIp";
          blockTTL = "10m";
          loading = {
            refreshPeriod = "24h";
            downloads.timeout = "60s";
          };
        };

        caching = {
          minTime = "5m";
          maxTime = "30m";
          prefetching = true;
        };

        prometheus.enable = true;
      };
    };

    systemd.services.blocky.serviceConfig.SupplementaryGroups = [ "certs" ];

    networking.firewall.allowedTCPPorts = [ 853 ];

    services.prometheus.scrapeConfigs = [{
      job_name = "blocky";
      static_configs = [{ targets = [ "localhost:4000" ]; }];
    }];
  };
}
