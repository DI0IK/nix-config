{ config, lib, pkgs, ... }:

{
  security.apparmor = {
    enable = true;
    packages = with pkgs; [ apparmor-profiles ];
  };

  systemd.package = pkgs.systemd.override {
    withApparmor = true;
  };
}