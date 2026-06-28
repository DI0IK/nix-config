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
      "/etc/ssh"
    ];

    files = [
      "/etc/machine-id"
    ];
  };

  environment.persistence."/persist" = {
    users.dominik = {
      directories = [
        ".local/state/pipewire"
        ".local/state/wireplumber"
      ];
    };
  };
}
