{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./kanshi.nix
    ./hyprpaper.nix
  ];

  # Shared uwsm env: ensures home-manager session vars propagate to uwsm-managed apps
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  # DE-adjacent packages shipped with the hyprland module
  home.packages = with pkgs; [
    hyprpolkitagent # polkit authentication agent
    pavucontrol # PulseAudio volume control
    adwaita-icon-theme
    brightnessctl # screen + keyboard backlight keys, and hypridle's dimming
    playerctl # multimedia transport keys
    grim # screenshot utility
    slurp # screen region selector
    librsvg # SVG pixbuf loader for GTK/wlogout
  ];

  # Run hyprpolkitagent as a monitored systemd user service so auth popups never die across switches
  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Authentication Agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
