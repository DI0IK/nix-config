{ ... }: {
  boot.plymouth.enable = true;
  catppuccin.plymouth.enable = true;

  boot.initrd.systemd.enable = true;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
}
