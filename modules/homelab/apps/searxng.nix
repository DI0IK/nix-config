{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homelab.apps.searxng = {
    enable = lib.mkEnableOption "SearXNG metasearch engine";
  };

  config = lib.mkIf config.homelab.apps.searxng.enable {
    services.searx = {
      enable = true;
      package = pkgs.searxng;
      settings = {
        use_default_settings = true;
        general = {
          instance_name = "dominikstahl search";
          enable_metrics = false;
        };
        server = {
          bind_address = "127.0.0.1";
          port = 8888;
          secret_key = "@SEARXNG_SECRET@";
          base_url = "https://search.dominikstahl.dev";
          limiter = true;
          public_instance = true;
          image_proxy = true;
          method = "GET";
        };
        search.autocomplete = "duckduckgo";
      };
      limiterSettings = {
        real_ip = {
          x_for = 1;
          ipv4_prefix = 32;
          ipv6_prefix = 48;
        };
        botdetection = {
          trusted_proxies = [
            "172.30.32.0/24"
            "127.0.0.0/8"
            "::1"
          ];
          ip_limit = {
            filter_link_local = true;
          };
        };
      };
      environmentFile = config.sops.templates.searxng-env.path;
    };

    homelab.traefik.apps.searxng = {
      host = "search.dominikstahl.dev";
      port = 8888;
    };

    sops.templates.searxng-env = {
      content = "SEARXNG_SECRET=${config.sops.placeholder.searxng-secret}";
    };

    sops.secrets.searxng-secret = { };
  };
}
