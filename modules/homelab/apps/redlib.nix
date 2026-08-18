{
  config,
  lib,
  ...
}:

{
  options.homelab.apps.redlib = {
    enable = lib.mkEnableOption "RedLib private Reddit frontend";
  };

  config = lib.mkIf config.homelab.apps.redlib.enable {
    services.redlib = {
      enable = true;
      port = 8080;
      address = "127.0.0.1";
      settings.REDLIB_ROBOTS_DISABLE_INDEXING = true;
    };

    homelab.traefik.apps.redlib = {
      host = "reddit.dominikstahl.dev";
      port = 8080;
    };
  };
}
