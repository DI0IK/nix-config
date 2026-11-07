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
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      tree = "eza --tree --icons";
      cat = "bat --paging=never";
      lg = "lazygit";
      rebuild = "nh os switch . -- --flake .#fw13";
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
