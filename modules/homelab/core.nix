{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homelab.core;
  pgDumpDir = "/persist/apps/postgres-dumps";
in
{
  options.homelab.core = {
    enable = lib.mkEnableOption "shared postgres + redis for homelab apps";
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /persist/apps 0755 root root -"
    ];

    services.postgresql = {
      enable = true;
      dataDir = "/persist/apps/postgres";
      authentication = ''
        local all all                 trust
        host  all all 127.0.0.1/32    scram-sha-256
        host  all all ::1/128         scram-sha-256
      '';
    };

    services.redis.servers."".enable = true;
    services.redis.servers."".bind = "127.0.0.1";
    services.redis.servers."".port = 6379;
    services.redis.servers."".settings.dir = lib.mkForce "/persist/apps/redis";

    systemd.services.pg-dump = {
      description = "Dump all postgres databases";
      path = [ pkgs.postgresql ];
      script = ''
        install -d -o postgres -g postgres -m 0700 ${pgDumpDir}
        for db in $(su postgres -s /bin/sh -c "psql -Atqc 'select datname from pg_database where datallowconn'" | grep -v postgres | grep -v template0); do
          su postgres -s /bin/sh -c "pg_dump -Fc $db" > ${pgDumpDir}/$db.dump
        done
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    systemd.timers.pg-dump = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
