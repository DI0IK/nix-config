{
  config,
  lib,
  ...
}:

{
  options.homelab.apps.homeassistant = {
    enable = lib.mkEnableOption "home assistant";
  };

  config = lib.mkIf config.homelab.apps.homeassistant.enable {
    services.home-assistant = {
      enable = true;
      configDir = "/persist/apps/hass";

      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = "Europe/Berlin";
        };
        default_config = { };
        mqtt = {
          broker = "127.0.0.1";
          port = 1883;
          username = "homeassistant";
          password = "!secret mqtt_password";
        };
        zha = "!include /persist/apps/hass/zha.yaml";
      };

      extraComponents = [
        "mqtt"
        "zha"
      ];
    };

    homelab.traefik.apps.homeassistant = {
      host = "hass.dominikstahl.dev";
      port = 8123;
    };

    sops.secrets."zha-ezsp-path" = { };

    sops.templates."homeassistant-secrets" = {
      path = "/persist/apps/hass/secrets.yaml";
      owner = "hass";
      content = ''
        mqtt_password: ${config.sops.placeholder."mqtt-password"}
      '';
    };

    sops.templates."homeassistant-zha" = {
      path = "/persist/apps/hass/zha.yaml";
      owner = "hass";
      content = ''
        zigpy_config:
          ezsp:
            path: tcp://${config.sops.placeholder."zha-ezsp-path"}
            baudrate: 115200
      '';
    };

    assertions = [
      {
        assertion = config.homelab.apps.mosquitto.enable;
        message = "homeassistant requires homelab.apps.mosquitto.enable to be true (local MQTT broker).";
      }
    ];
  };
}
