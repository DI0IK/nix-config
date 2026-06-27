{ pkgs, ... }:

{
  programs.zsh.enable = true;

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
  };
}
