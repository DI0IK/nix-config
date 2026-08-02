{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /home/dominik/Pictures/Camera 0755 dominik users -"
    "d /home/dominik/Videos/Camera 0755 dominik users -"
  ];

  environment.etc."crypttab".text = ''
    bilder UUID=69eb692a-5b5a-495c-97e8-239bf695c6a9 /persist/crypto_keyfile.bin luks,nofail
  '';

  fileSystems = {
    "/home/dominik/Pictures/Camera" = {
      device = "/dev/mapper/bilder";
      fsType = "btrfs";
      options = [
        "subvol=/@images"
        "rw"
        "relatime"
        "ssd"
        "space_cache=v2"
        "users"
        "nofail"
        "x-systemd.device-timeout=100ms"
        "x-systemd.automount"
        "x-systemd.idle-timeout=20min"
      ];
    };

    "/home/dominik/Videos/Camera" = {
      device = "/dev/mapper/bilder";
      fsType = "btrfs";
      options = [
        "subvol=/@videos"
        "rw"
        "relatime"
        "ssd"
        "space_cache=v2"
        "users"
        "nofail"
        "x-systemd.device-timeout=100ms"
        "x-systemd.automount"
        "x-systemd.idle-timeout=20min"
      ];
    };
  };

  services.udev.extraRules = ''
    # Ignore the underlying LUKS drive by UUID
    ENV{ID_FS_UUID}=="69eb692a-5b5a-495c-97e8-239bf695c6a9", ENV{UDISKS_IGNORE}="1"

    # Ignore the unlocked mapper device
    KERNEL=="bilder", ENV{UDISKS_IGNORE}="1"
  '';

  services.udisks2.enable = true;
}
