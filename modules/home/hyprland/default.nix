{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    ./hyprlock.nix
    ./hypridle.nix
  ];

  # Shared uwsm env: ensures home-manager session vars propagate to uwsm-managed apps
  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  # DE-adjacent packages shipped with the hyprland module
  home.packages = with pkgs; [
    hyprpolkitagent   # polkit authentication agent
    pavucontrol       # PulseAudio volume control
    adwaita-icon-theme
  ];
}
