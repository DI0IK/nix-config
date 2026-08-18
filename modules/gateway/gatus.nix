{
  config,
  lib,
  ...
}:

let
  cfg = config.gateway.gatus;
in
{
  options.gateway.gatus = {
    enable = lib.mkEnableOption "Gatus health checker";
  };

  config = lib.mkIf cfg.enable {
    services.gatus = {
      enable = true;
      environmentFile = config.sops.templates.gatus-env.path;
      settings = {
        web.port = 8080;
        storage = {
          type = "file";
          path = "/persist/apps/gatus";
        };
        endpoints = [
          {
            name = "authentik";
            url = "https://sso.dominikstahl.dev";
            interval = "1m";
            conditions = [
              "[STATUS] == 200"
              "[RESPONSE_TIME] < 5000"
            ];
          }
          {
            name = "home-assistant";
            url = "https://hass.dominikstahl.dev";
            interval = "1m";
            conditions = [
              "[STATUS] == 200"
              "[RESPONSE_TIME] < 5000"
            ];
          }
          {
            name = "searxng";
            url = "https://search.dominikstahl.dev";
            interval = "1m";
            conditions = [
              "[STATUS] == 200"
              "[RESPONSE_TIME] < 5000"
            ];
          }
          {
            name = "redlib";
            url = "https://reddit.dominikstahl.dev";
            interval = "1m";
            conditions = [
              "[STATUS] == 200"
              "[RESPONSE_TIME] < 5000"
            ];
          }
          {
            name = "homelab-ssh";
            url = "tcp://172.30.32.2:22";
            interval = "1m";
            conditions = [ "[CONNECTED] == true" ];
          }
          {
            name = "homelab-traefik-http";
            url = "tcp://172.30.32.2:80";
            interval = "1m";
            conditions = [ "[CONNECTED] == true" ];
          }
          {
            name = "homelab-traefik-https";
            url = "tcp://172.30.32.2:443";
            interval = "1m";
            conditions = [ "[CONNECTED] == true" ];
          }
        ];
        alerting = {
          discord = {
            webhook-url = "\${DISCORD_WEBHOOK_URL}";
            default-alert-endpoint = "discord";
            default-labels.severity = "warning";
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /persist/apps 0755 root root -"
      "d /persist/apps/gatus 0755 gatus gatus -"
    ];

    sops.templates.gatus-env = {
      content = "DISCORD_WEBHOOK_URL=${config.sops.placeholder.discord-webhook-url}";
    };

    sops.secrets.discord-webhook-url = { };
  };
}
