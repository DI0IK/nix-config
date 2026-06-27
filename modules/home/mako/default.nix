{ config, lib, pkgs, theme, ... }:
{
  services.mako = {
    enable = true;

    settings = {
      background-color = theme.base;
      text-color = theme.text;
      border-color = theme.blue;
      progress-color = "over ${theme.surface0}";

      font = "monospace 10";
      border-radius = 5;
      border-size = 2;
      padding = "10,15";
      default-timeout = 5000;
    };

    extraConfig = ''
      [urgency=high]
      border-color=${theme.peach}
      default-timeout=0
    '';
  };
}