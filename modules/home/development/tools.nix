{ pkgs, ... }: {
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    # Scripting runtimes
    python3
    nodejs

    # Modern CLI power tools
    comma
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
  ];
}
