{ ... }: {
  services.fprintd.enable = true;

  environment.persistence."/persist".directories = [
    "/var/lib/fprint"
  ];

  security.pam.services.hyprlock = { };
}
