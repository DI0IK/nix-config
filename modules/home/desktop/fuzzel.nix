{
  pkgs,
  lib,
  theme ? import ../../shared/theme.nix,
  ...
}:
let
  strip = c: lib.strings.removePrefix "#" c;
in
{
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        font = "JetBrainsMono Nerd Font Propo:size=13";
        terminal = "${pkgs.kitty}/bin/kitty";
        prompt = "\"󰍉    \"";
        placeholder = "Search applications...";
        icon-theme = "Adwaita";
        icons-enabled = true;
        fields = "name,generic,comment,categories,filename,keywords";
        lines = 10;
        width = 42;
        horizontal-pad = 24;
        vertical-pad = 16;
        inner-pad = 10;
        image-size-ratio = 0.5;
        line-height = 26;
        anchor = "center";
      };

      colors = {
        background = "${strip theme.base}dd";
        text = "${strip theme.text}ff";
        prompt = "${strip theme.mauve}ff";
        placeholder = "${strip theme.overlay0}ff";
        input = "${strip theme.text}ff";
        match = "${strip theme.mauve}ff";
        selection = "${strip theme.surface0}cc";
        selection-text = "${strip theme.text}ff";
        selection-match = "${strip theme.pink}ff";
        border = "${strip theme.mauve}ee";
      };

      border = {
        width = 2;
        radius = 12;
      };
    };
  };
}
