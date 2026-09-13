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

  xdg.configFile."driftwm/config.toml".text = ''
    autostart = ["mako"]

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

    [keybindings]
    "mod+return" = "exec kitty"
    "mod+escape" = "exec wlogout"
    "mod+f" = "toggle-fullscreen"
    "mod+m" = "fit-window"
    "mod+d" = "exec fuzzel"

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
