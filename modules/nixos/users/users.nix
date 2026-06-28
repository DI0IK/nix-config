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

  environment.systemPackages = with pkgs; [
    kitty.terminfo
  ];
}
