{ config, lib, pkgs, theme, ... }:
{
  services.mako = {
    enable = true;

    backgroundColor = theme.base;
    textColor = theme.text;
    borderColor = theme.blue;
    progressColor = "over ${theme.surface0}";

    font = "monospace 10";
    borderRadius = 5;
    borderSize = 2;
    padding = "10,15";
    defaultTimeout = 5000;

    extraConfig = ''
      [urgency=high]
      border-color=${theme.peach}
      default-timeout=0
    '';
  };
}