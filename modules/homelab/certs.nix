{ config, lib, ... }:

let
  cfg = config.homelab.certs;
  certName = "dominikstahl";
in
{
  options.homelab.certs = {
    enable = lib.mkEnableOption "shared wildcard cert via security.acme (lego)";

    email = lib.mkOption {
      type = lib.types.str;
      default = "admin@dominikstahl.dev";
      description = "Let's Encrypt account email.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "dominikstahl.dev";
      description = "Apex domain; the wildcard `*.<domain>` is included as a SAN.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = cfg.email;
    };

    security.acme.certs.${certName} = {
      domain = cfg.domain;
      extraDomainNames = [ "*.${cfg.domain}" ];
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.cloudflare-api-token.path;
      group = "traefik";
      reloadServices = [ "traefik.service" ];
    };

    sops.secrets."cloudflare-api-token" = {
      mode = "0400";
      owner = "acme";
    };

    environment.persistence."/persist".directories = [ "/var/lib/acme" ];
  };
}
