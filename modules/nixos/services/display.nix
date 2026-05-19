{ config, lib, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time --asterisks --remember --user-menu --user-menu-min-uid 1000 \
          --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions \
          --cmd Hyprland
      '';
      user = "greeter";
    };
  };
}