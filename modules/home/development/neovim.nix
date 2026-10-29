{ inputs, pkgs, ... }: {
  imports = [
    inputs.lazyvim.homeManagerModules.default
  ];

  programs.lazyvim = {
    enable = true;

    extras = {
      # Languages
      lang.nix.enable = true;
      lang.rust = {
        enable = true;
        installDependencies = true;
      };
      lang.typescript = {
        enable = true;
        installDependencies = true;
        biome = {
          enable = true;
          installDependencies = true;
        };
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
      lang.toml.enable = true;
      lang.git.enable = true;
      lang.java.enable = true;
      lang.kotlin.enable = true;
      formatting.prettier.enable = true;

      # Debugging & Testing
      dap.core.enable = true;
      test.core.enable = true;

      # Navigation & UI
      editor.aerial.enable = true;
      editor.inc-rename.enable = true;
      ui.treesitter-context.enable = true;

      # AI & Coding
      ai.copilot.enable = true;
      coding.neogen.enable = true;
    };

    extraPackages = with pkgs; [
      nodejs
      nixd
      marksman
      rustfmt
      clippy
      typescript-language-server
      prettier
      biome
      taplo
      lldb

      # Android / JVM
      jdt-language-server
      kotlin-language-server
      ktlint
      jdk17
      gradle
      android-tools
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
      ".config/github-copilot"
    ];
  };
}
