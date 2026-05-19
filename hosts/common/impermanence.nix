{ config, ... }:

{
  fileSystems."/persist".neededForBoot = true;

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/greetd"
    ];

    files = [
      "/etc/machine-id"
    ];

    users.dominik = {
      directories = [
        ".local/state/pipewire"
        ".local/state/wireplumber"
      ];
    };
  };
}