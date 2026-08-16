{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.monitoring;
in
{
    options.homelab.monitoring = {
      enable = lib.mkEnableOption "monitoring stack (prometheus, grafana, loki, alloy)";
    };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /persist/apps 0755 root root -"
      "d /persist/apps/prometheus 0755 prometheus prometheus -"
      "d /persist/apps/grafana 0755 grafana grafana -"
      "d /persist/apps/grafana/dashboards 0755 grafana grafana -"
      "d /persist/apps/loki 0755 loki loki -"
      "d /persist/apps/alloy 0755 root root -"
    ];

    # ── Prometheus ──────────────────────────────────────────────
    services.prometheus = {
      enable = true;
      port = 9090;
      listenAddress = "127.0.0.1";
      stateDir = "/persist/apps/prometheus";
      retentionTime = "30d";
      globalConfig = {
        scrape_interval = "30s";
        evaluation_interval = "30s";
      };
      scrapeConfigs = [
        {
          job_name = "node-homelab";
          static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
        {
          job_name = "node-gateway";
          static_configs = [{
            targets = [ "172.30.32.1:9100" ];
          }];
        }
      ];
    };

    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      listenAddress = "127.0.0.1";
    };

    # ── Grafana ─────────────────────────────────────────────────
    services.grafana = {
      enable = true;
      dataDir = "/persist/apps/grafana";
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          domain = "grafana.dominikstahl.dev";
          root_url = "https://grafana.dominikstahl.dev";
        };
        security = {
          admin_user = "admin";
          admin_password = "$__env{GF_SECURITY_ADMIN_PASSWORD}";
          secret_key = "$__env{GF_SECURITY_SECRET_KEY}";
        };
        users.allow_sign_up = true;
        "auth.generic_oauth" = {
          enabled = true;
          name = "Authentik";
          allow_sign_up = true;
          auto_login = false;
          client_id = "grafana-client";
          client_secret = "$__env{GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET}";
          scopes = [ "openid" "profile" "email" "groups" ];
          auth_url = "https://sso.dominikstahl.dev/application/o/authorize/";
          token_url = "https://sso.dominikstahl.dev/application/o/token/";
          api_url = "https://sso.dominikstahl.dev/application/o/userinfo/";
          use_pkce = true;
          use_refresh_token = true;
          role_attribute_path = "contains(groups, 'Grafana Admins') && 'Admin' || 'Viewer'";
          email_attribute_path = "email";
          login_attribute_path = "preferred_username";
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
      };
    };

    systemd.services.grafana.environment = {
      GF_SECURITY_ADMIN_PASSWORD = config.sops.placeholder.grafana-admin-password;
      GF_SECURITY_SECRET_KEY = config.sops.placeholder.grafana-secret-key;
      GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET = config.sops.placeholder.grafana-oauth-client-secret;
    };

    sops.secrets = {
      grafana-admin-password = { };
      grafana-secret-key = { };
      grafana-oauth-client-secret = { };
    };

    # ── Loki ────────────────────────────────────────────────────
    services.loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 3100;
        auth_enabled = false;
        common = {
          path_prefix = "/persist/apps/loki";
          storage.filesystem = {
            chunks_directory = "/persist/apps/loki/chunks";
            rules_directory = "/persist/apps/loki/rules";
          };
          replication_factor = 1;
          ring.kvstore.store = "inmemory";
        };
        schema_config.configs = [{
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
        limits_config = {
          retention_period = "30d";
          max_query_length = "721h";
        };
        compactor = {
          working_directory = "/persist/apps/loki/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          retention_delete_delay = "2h";
          retention_delete_worker_count = 150;
          delete_request_store = "filesystem";
        };
      };
    };

    # ── Alloy (log shipper, replaces promtail) ──────────────────
    services.alloy = {
      enable = true;
      configPath = builtins.toFile "config.alloy" ''
        logging {
          level = "warn"
        }

        loki.relabel "journal" {
          forward_to = []

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "systemd_unit"
          }
          rule {
            source_labels = ["__journal__hostname"]
            target_label  = "hostname"
          }
        }

        loki.source.journal "journal" {
          forward_to    = [loki.write.local.receiver]
          relabel_rules = loki.relabel.journal.rules
          max_age       = "24h"
          path          = "/var/log/journal"
          labels        = { job = "systemd-journal", host = "homelab" }
        }

        loki.write "local" {
          endpoint {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
          }
        }
      '';
    };

    # ── Traefik route (no forward-auth, Grafana uses OIDC) ──────
    homelab.traefik.apps.grafana = {
      host = "grafana.dominikstahl.dev";
      port = 3000;
    };

    # ── Authentik blueprint for Grafana OIDC ────────────────────
    homelab.authentik.apps.grafana = {
      type = "oidc";
      name = "Grafana";
      group = "Grafana";
      roleGroups = [ "Admins" "Editors" ];
      clientId = "grafana-client";
      clientSecret = config.sops.placeholder.grafana-oauth-client-secret;
      redirectUris = [
        {
          url = "https://grafana.dominikstahl.dev/login/generic_oauth";
          matching_mode = "strict";
        }
      ];
      scopes = [
        "openid"
        "profile"
        "email"
        "groups"
      ];
      accessTokenValidity = "hours=16";
    };
  };
}
