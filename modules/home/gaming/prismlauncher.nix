{ pkgs, ... }:

{
  home.packages = [
    (pkgs.prismlauncher.override {
      jdks = with pkgs; [
        temurin-bin-25
        temurin-bin-21
        temurin-bin-17
        temurin-bin-8
      ];
    })
  ];

  home.persistence."/persist" = {
    directories = [
      ".local/share/PrismLauncher"
    ];
  };
}
