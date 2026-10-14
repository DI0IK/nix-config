{ pkgs, lib, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # Runtime dependencies for LazyVim, plugins, and Treesitter/Mason
      git
      gcc
      gnumake
      ripgrep
      fd
      unzip
      curl
      nodejs
    ];
  };

  home.persistence."/persist" = {
    directories = [
      ".config/nvim"
      ".local/share/nvim"
      ".local/state/nvim"
    ];
  };

  home.activation.installLazyVim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
      mkdir -p "$HOME/.config/nvim"
      ${pkgs.git}/bin/git clone https://github.com/LazyVim/starter /tmp/lazyvim-starter 2>/dev/null || true
      if [ -d /tmp/lazyvim-starter ]; then
        cp -rn /tmp/lazyvim-starter/. "$HOME/.config/nvim/" 2>/dev/null || true
        rm -rf /tmp/lazyvim-starter "$HOME/.config/nvim/.git"
      fi
    fi
  '';
}
