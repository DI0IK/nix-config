{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      # Setting theme to "" cleanly disables OMZ prompt themes so Starship manages the prompt without conflicts
      theme = "";
      plugins = [
        "git"
        "sudo"
      ];
    };

    shellAliases = {
      sudo = "run0";
      ls = "eza --icons=auto";
      ll = "eza -l --icons=auto --git";
      la = "eza -la --icons=auto --git";
      tree = "eza --tree --icons=auto";
      cat = "bat --paging=never";
      lg = "lazygit";
      rebuild = "nh os switch /persist/nix-config";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
  };
}
