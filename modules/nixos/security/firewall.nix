{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.firewall = {
    enable = true;
    allowPing = false;
    checkReversePath = "loose";
    trustedInterfaces = [ "virbr0" ];
  };

  environment.systemPackages = with pkgs; [
    iptables
  ];
}
