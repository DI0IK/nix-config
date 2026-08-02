{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    btop
    yazi
    wl-clipboard

    # GUI Applications
    vscodium-fhs
    antigravity-fhs
    libreoffice-fresh
    mpv
    darktable
    (pkgs.jetbrains.idea.override {
      vmopts = ''
        -Dawt.toolkit.name=WLToolkit
      '';
    })
    opencode
    cura-appimage

    # Utilities
    brightnessctl
    playerctl
  
    sops
    age-plugin-yubikey
  ];

  programs.zoxide.enable = true;

  programs.neovim.enable = true;

  services.udiskie.enable = true;

  programs.git = {
    enable = true;
    settings.user.name = "Dominik Stahl";
    settings.user.email = "dominik@samdj.de";

    signing = {
      key = null;
      signByDefault = true; 
    };
  };
}
