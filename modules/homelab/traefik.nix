{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homelab.traefik;
  certPath = "/var/lib/acme/dominikstahl";
in
{
  options.homelab.traefik = {
    enable = lib.mkEnableOption "traefik reverse proxy";

    apps = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              description = "Hostname this app is routed under.";
            };
            port = lib.mkOption {
              type = lib.types.port;
              description = "Local port the app listens on.";
            };
          };
        }
      );
      default = { };
      description = "Traefik routes for local systemd apps: name -> { host, port }.";
    };
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

        http = {
          routers = lib.mapAttrs' (
            name: app:
            lib.nameValuePair name {
              rule = "Host(`${app.host}`)";
              service = name;
              entryPoints = [ "websecure" ];
              tls = { };
            }
          ) cfg.apps;
          services = lib.mapAttrs (name: app: {
            loadBalancer.servers = [
              { url = "http://127.0.0.1:${toString app.port}"; }
            ];
          }) cfg.apps;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [ 443 ];
  };
}
