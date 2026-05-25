{ pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  
    config.global.hide_env_diff = true;
  };

  home.packages = [
    pkgs.devenv
  ];
}