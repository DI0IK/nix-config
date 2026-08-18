{ config, lib, ... }:

let
  cfg = config.homelab.media;
in
{
  options.homelab.media = {
    enable = lib.mkEnableOption "NFS media mount";

    nfsServer = lib.mkOption {
      type = lib.types.str;
      default = "192.168.179.10";
    };

    nfsPath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/user/media";
    };

    mountPoint = lib.mkOption {
      type = lib.types.str;
      default = "/media";
    };
  };

  config = lib.mkIf cfg.enable {
    fileSystems."${cfg.mountPoint}" = {
      device = "${cfg.nfsServer}:${cfg.nfsPath}";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "x-systemd.automount"
        "x-systemd.idle-timeout=300"
        "noatime"
        "nofail"
      ];
    };
  };
}
