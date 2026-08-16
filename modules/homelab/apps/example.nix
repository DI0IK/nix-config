{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.homelab.apps.example = {
    enable = lib.mkEnableOption "example web app";
  };

  config = lib.mkIf config.homelab.apps.example.enable {
    homelab.traefik.apps.example = {
      host = "example.dominikstahl.dev";
      port = 8080;
    };

    systemd.services.example = {
      description = "Example app";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8080 --bind 127.0.0.1";
        Restart = "on-failure";
      };
    };
  };
}
