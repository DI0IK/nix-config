{ pkgs, ... }:

{
  # Enable OpenRGB server and udev rules for non-root hardware access
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb;
    motherboard = "amd";
  };

  # Make openrgb CLI available system-wide
  environment.systemPackages = [ pkgs.openrgb ];
}
