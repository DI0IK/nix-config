{ ... }: {
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNS = "217.154.87.4#dominik-fw13.dns.dominikstahl.dev";
        Domains = "~.";
        DNSOverTLS = "yes";
        DNSSEC = "true";
      };
    };
  };
}
