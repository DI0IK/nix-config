{ ... }:
{
  imports = [
    ./authentik.nix
    ./example.nix
    ./homeassistant.nix
    ./mosquitto.nix
    ./redlib.nix
    ./searxng.nix
  ];
}
