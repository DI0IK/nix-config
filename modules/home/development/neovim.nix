{ inputs, pkgs, ... }: {
  imports = [
    inputs.lazyvim.homeManagerModules.default
  ];

  programs.lazyvim = {
    enable = true;

    extras = {
      lang.nix.enable = true;
      lang.rust = {
        enable = true;
        installDependencies = true;
      };
      lang.typescript = {
        enable = true;
        installDependencies = true;
      };
      lang.markdown = {
        enable = true;
        installDependencies = true;
      };
      lang.json = {
        enable = true;
        installDependencies = true;
      };
      lang.yaml.enable = true;
      formatting.prettier.enable = true;
    };

    extraPackages = with pkgs; [
      nixd
      marksman
      rustfmt
      clippy
      typescript-language-server
      prettier
    ];
  };

  programs.neovim = {
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.persistence."/persist" = {
    directories = [
      ".local/share/nvim"
      ".local/state/nvim"
    ];
  };
}
