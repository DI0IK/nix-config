{
  pkgs,
  lib,
  theme,
  ...
}:

let
  inherit (theme) green maroon base mantle text;
  color = c: "#${lib.strings.removePrefix "#" c}";
in
{
  home.persistence."/persist".directories = [
    ".config/driftwm"
  ];

  xdg.configFile."driftwm/config.toml".text = ''
    autostart = ["waybar", "fuzzel", "mako"]

    [input.keyboard]
    layout = "de"
    variant = "neo_qwertz"

    [cursor]
    theme = "Adwaita"
    size = 18

    [decorations]
    bg_color = "${color base}"
    fg_color = "${color text}"
    corner_radius = 5
    border_width = 2
    border_color = "${color maroon}"
    border_color_focused = "${color green}"

    [[window_rules]]
    app_id = "pinentry"
    decoration = "none"

    [[window_rules]]
    app_id = "firefox"
    blur = true

    [[window_rules]]
    app_id = "chromium"
    blur = true
  '';
}
