{ config, lib, ... }:

{
  networking.firewall = {
    enable = true;
    allowPing = false;
  };
}