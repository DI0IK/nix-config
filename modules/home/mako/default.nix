{ config, lib, pkgs, ... }:

{
  services.mako = {
    enable = true;

    backgroundColor = "#1e1e2e";
    textColor = "#cdd6f4";
    borderColor = "#89b4fa";
    progressColor = "over #313244";
    
    font = "monospace 10";
    borderRadius = 5;
    borderSize = 2;
    padding = "10,15";
    defaultTimeout = 5000;

    extraConfig = ''
      [urgency=high]
      border-color=#fab387
      default-timeout=0
    '';
  };
}