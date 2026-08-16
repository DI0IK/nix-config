{
  config,
  lib,
  ...
}:

{
  options.homelab.apps.authentik = {
    enable = lib.mkEnableOption "authentik identity provider";
  };

  config = lib.mkIf config.homelab.apps.authentik.enable {
    services.authentik = {
      enable = true;
      createDatabase = true;
      environmentFile = config.sops.secrets.authentik-env.path;
      nginx.enable = false;
      settings = {
        redis = {
          host = "127.0.0.1";
          port = 6379;
        };
        storage.media.file.path = "/persist/apps/authentik";
      };
    };

    users.users.authentik = {
      isSystemUser = true;
      group = "authentik";
      home = "/persist/apps/authentik";
      createHome = false;
    };
    users.groups.authentik = { };

    systemd.tmpfiles.rules = [
      "d /var/lib/authentik 0700 authentik authentik -"
      "d /persist/apps/authentik 0700 authentik authentik -"
    ];

    systemd.services = {
      authentik.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
      };
      authentik-worker.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
      };
      authentik-migrate.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "authentik";
        Group = "authentik";
      };
    };

    homelab.traefik.apps.authentik = {
      host = "sso.dominikstahl.dev";
      port = 9000;
    };

    sops.secrets.authentik-env = {
      owner = "root";
      mode = "0400";
    };
  };
}
