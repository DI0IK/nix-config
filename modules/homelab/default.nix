{ ... }:
{
  imports = [
    ./apps
    ./certs.nix
    ./core.nix
    ./traefik.nix
    ./wireguard.nix
  ];

  homelab.certs.enable = true;
  homelab.core.enable = true;
  homelab.traefik.enable = true;
  homelab.wireguard.enable = true;

  homelab.apps.authentik.enable = true;
}
