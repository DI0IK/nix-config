{ config, lib, pkgs, theme, ... }:

let
  # Fuzzel uses ARGB hex (no leading #) — strip the # and append alpha
  alpha = "dd";
  full  = "ff";

  stripHash = s: builtins.substring 1 6 s;
  argb = color: a: "${stripHash color}${a}";
in {
  programs.fuzzel = {
    enable = true;

    # The idiomatic Nix way: strongly typed configuration blocks
    settings = {
      main = {
        width = 50;
        terminal = "${pkgs.kitty}/bin/kitty"; # Ensures fuzzel knows your secure terminal path
      };

      colors = {
        background        = argb theme.base alpha;
        text              = argb theme.text full;
        prompt            = argb theme.subtext1 full;
        placeholder       = argb theme.overlay1 full;
        input             = argb theme.text full;
        match             = argb theme.blue full;
        selection         = argb theme.surface2 full;
        "selection-text"  = argb theme.text full;
        "selection-match" = argb theme.blue full;
        counter           = argb theme.overlay1 full;
        border            = argb theme.blue full;
      };
    };
  };
}