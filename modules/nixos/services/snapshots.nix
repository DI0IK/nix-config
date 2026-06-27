{ pkgs, ... }: {
  # Write the btrbk configuration file directly to /etc/btrbk.conf
  environment.etc."btrbk.conf".text = ''
    snapshot_preserve_min latest
    snapshot_preserve 24h 7d 4w

    volume /persist
      subvolume .
      snapshot_dir .snapshots
  '';

  # Install the btrbk package
  environment.systemPackages = [ pkgs.btrbk ];

  # Run btrbk via systemd timer
  systemd.services.btrbk-local = {
    description = "Btrbk local snapshot service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.btrbk}/bin/btrbk run";
    };
  };

  systemd.timers.btrbk-local = {
    description = "Btrbk local snapshot timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  # Ensure the snapshot directory exists
  systemd.tmpfiles.rules = [
    "d /persist/.snapshots 0700 root root - -"
  ];
}
