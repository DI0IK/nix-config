{ ... }:
{
  imports = [
    ./apps
    ./blocky.nix
    ./certs.nix
    ./core.nix
    ./media.nix
    ./monitoring.nix
    ./traefik.nix
    ./wireguard.nix
  ];

  homelab.blocky.enable = true;
  homelab.certs.enable = true;
  homelab.core.enable = true;
  homelab.media.enable = true;
  homelab.monitoring.enable = true;
  homelab.traefik.enable = true;
  homelab.wireguard.enable = true;

  homelab.apps.authentik.enable = true;
  homelab.apps.homeassistant.enable = true;
  homelab.apps.mosquitto.enable = true;
  homelab.apps.redlib.enable = true;
  homelab.apps.searxng.enable = true;
}
