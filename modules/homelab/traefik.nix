{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.traefik;
  certPath = "/var/lib/acme/dominikstahl";
in
{
  options.homelab.traefik = {
    enable = lib.mkEnableOption "traefik reverse proxy";
  };

  config = lib.mkIf cfg.enable {
    services.traefik = {
      enable = true;

      staticConfigOptions = {
        entryPoints = {
          http = {
            address = ":80";
            proxyProtocol.trustedIPs = [ "172.30.32.1/32" ];
          };
          websecure = {
            address = ":443";
            proxyProtocol.trustedIPs = [ "172.30.32.1/32" ];
          };
        };
        log.level = "INFO";
      };

      dynamicConfigOptions = {
        tls.stores.default.defaultCertificate = {
          certFile = "${certPath}/fullchain.pem";
          keyFile = "${certPath}/key.pem";
        };
      };
    };
  };
}
