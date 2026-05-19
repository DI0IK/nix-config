{ config, lib, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --time --asterisks --remember --user-menu --user-menu-min-uid 1000 \
          --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions
      '';
      user = "greeter";
    };
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.hyprdynamicmonitors = {
    enable = true;
  };

  security.pam.services.hyprlock = {};
}