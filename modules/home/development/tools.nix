{ pkgs, ... }:
let
  google-colab-cli = pkgs.python3Packages.callPackage ./google-colab-cli/package.nix { };
in
{
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  home.packages = with pkgs; [
    # Scripting runtimes
    python3
    nodejs

    # Modern CLI power tools
    eza
    bat
    fastfetch
    lazygit
    nh
    dua

    # Data & text processing
    jq
    yq-go
    gnused
    gawk

    # Search & navigation
    ripgrep
    fd

    # Shell scripting helpers
    shellcheck
    shfmt

    # System & network inspection
    tree
    file
    which
    curl
    wget
    httpie
    unzip
    zip

    # Git
    gh
    glab

    # Cloud / Notebooks
    google-colab-cli
  ];

  home.persistence."/persist".directories = [
    ".config/gh"
    ".config/glab-cli"
    ".config/colab-cli"
  ];
}
