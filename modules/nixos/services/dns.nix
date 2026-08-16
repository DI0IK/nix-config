{ config, lib, ... }:
{
  options.networking.dnsOverTls = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "DNS-over-TLS upstream, e.g. '1.1.1.1#one.one.one.one'. Empty disables the override.";
  };

  config = lib.mkIf (config.networking.dnsOverTls != "") {
    services.resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNS = config.networking.dnsOverTls;
          Domains = "~.";
          DNSOverTLS = "yes";
          DNSSEC = "true";
        };
      };
    };
  };
}
