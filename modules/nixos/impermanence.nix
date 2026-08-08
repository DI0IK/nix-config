{ ... }:
{
  fileSystems."/persist".neededForBoot = true;

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/etc/ssh"
    ];

    files = [
      "/etc/machine-id"
    ];
  };
}
