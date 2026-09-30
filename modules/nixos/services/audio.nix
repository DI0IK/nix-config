{
  config,
  lib,
  pkgs,
  ...
}:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # wpctl for the session / binds, pw-cli & pw-top for debugging
  environment.systemPackages = with pkgs; [
    pipewire
    wireplumber
  ];
}
