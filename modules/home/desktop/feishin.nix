{ pkgs, ... }:
{
  home.packages = [
    pkgs.feishin
  ];

  # Persist Feishin state, caches, and server accounts across impermanence boots
  home.persistence."/persist" = {
    directories = [
      ".config/feishin"
    ];
  };
}
