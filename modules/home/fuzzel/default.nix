{ config, lib, pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;

    # The idiomatic Nix way: strongly typed configuration blocks
    settings = {
      main = {
        width = 50;
        terminal = "${pkgs.kitty}/bin/kitty"; # Ensures fuzzel knows your secure terminal path
      };

      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        prompt = "bac2deff";
        placeholder = "7f849cff";
        input = "cdd6f4ff";
        match = "89b4faff";
        selection = "585b70ff";
        "selection-text" = "cdd6f4ff";  # Quoted because of the hyphen
        "selection-match" = "89b4faff"; # Quoted because of the hyphen
        counter = "7f849cff";
        border = "89b4faff";
      };
    };
  };
}