{
  config,
  lib,
  ...
}:

{
  options.homelab.apps.mosquitto = {
    enable = lib.mkEnableOption "mosquitto MQTT broker";
  };

  config = lib.mkIf config.homelab.apps.mosquitto.enable {
    services.mosquitto = {
      enable = true;
      dataDir = "/persist/apps/mosquitto";
      listeners = [
        {
          address = "0.0.0.0";
          port = 1883;
          users.homeassistant.passwordFile = config.sops.secrets."mqtt-password".path;
        }
      ];
    };

    sops.secrets."mqtt-password" = { };
  };
}
