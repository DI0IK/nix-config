{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "sudo"
      ];
    };  
    
    shellAliases = {
      sudo = "run0";
    };
  };

  users.users.dominik = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.dominik-password.path;
  };


  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    JAVA_TOOL_OPTIONS = "-Dawt.toolkit.name=WLToolkit";
  };

  environment.systemPackages = with pkgs; [
    kitty.terminfo
  ];
}
