{
  pkgs,
  lib,
  theme,
  ...
}:
{
  programs.wlogout = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "wlogout-wrapped";
      paths = [ pkgs.wlogout ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/wlogout \
          --set GDK_PIXBUF_MODULE_FILE "${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
      '';
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = false;
    package = null;
    portalPackage = null;

    settings = { };

    extraConfig = ''
      local mainMod = "SUPER"

      local brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl"
      local wpctl         = "${pkgs.wireplumber}/bin/wpctl"
      local playerctl     = "${pkgs.playerctl}/bin/playerctl"
      local grim          = "${pkgs.grim}/bin/grim"
      local slurp         = "${pkgs.slurp}/bin/slurp"
      local wlcopy        = "${pkgs.wl-clipboard}/bin/wl-copy"
      local swayosd       = "${pkgs.swayosd}/bin/swayosd-client"
      local swaync        = "${pkgs.swaynotificationcenter}/bin/swaync-client"
      local wlogout       = "GDK_PIXBUF_MODULE_FILE=${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache ${pkgs.wlogout}/bin/wlogout"

      hl.env("XCURSOR_THEME", "catppuccin-mocha-mauve-cursors")
      hl.env("XCURSOR_SIZE", "24")
      hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-mauve-cursors")
      hl.env("HYPRCURSOR_SIZE", "24")

      -- ░░░░░░░░░░  LOOK AND FEEL  ░░░░░░░░░░

      hl.config({
          general = {
              gaps_in       = 3,
              gaps_out      = 8,
              border_size   = 2,
              col = {
                  active_border   = "rgba(${lib.strings.removePrefix "#" theme.mauve}ee)",
                  inactive_border = "rgba(${lib.strings.removePrefix "#" theme.surface1}88)",
              },
          },
          decoration = {
              rounding          = 8,
              rounding_power    = 2,
              active_opacity    = 1.0,
              inactive_opacity  = 0.96,
              blur = {
                  enabled           = true,
                  size              = 6,
                  passes            = 2,
                  new_optimizations = true,
                  ignore_opacity    = true,
                  xray              = false,
              },
              shadow = {
                  enabled        = true,
                  range          = 15,
                  render_power   = 3,
                  color          = "rgba(${lib.strings.removePrefix "#" theme.base}88)",
                  color_inactive = "rgba(${lib.strings.removePrefix "#" theme.mantle}44)",
              },
          },
          animations = {
              enabled = true,
          },
          misc = {
              force_default_wallpaper = -1,
              disable_hyprland_logo   = true,
          },
          xwayland = {
              enabled            = true,
              force_zero_scaling = true,
          },
      })

      -- ░░░░░░░░░░  ANIMATIONS  ░░░░░░░░░░

      hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
      hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
      hl.curve("overshoot",      { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

      hl.animation({ leaf = "windows",       enabled = true, speed = 3.5, bezier = "overshoot",    style = "popin 85%" })
      hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.0, bezier = "overshoot",    style = "popin 85%" })
      hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "popin 90%" })
      hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2.5, bezier = "default" })
      hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2.0, bezier = "default" })
      hl.animation({ leaf = "workspaces",    enabled = true, speed = 4.0, bezier = "easeOutQuint", style = "slide" })

      -- ░░░░░░░░░░  INPUT  ░░░░░░░░░░

      hl.config({
          input = {
              kb_layout    = "de",
              kb_variant   = "neo_qwertz",
              follow_mouse = 1,
              sensitivity  = 0,
              touchpad = {
                  natural_scroll = true,
              },
          },
      })

      -- ░░░░░░░░░░  MONITORS  ░░░░░░░░░░

      hl.monitor({
          output   = "",
          mode     = "preferred",
          position = "auto",
          scale    = "auto",
      })

      hl.monitor({
          output   = "eDP-1",
          mode     = "2256x1504@60.00",
          position = "0x0",
          scale    = 1.5666666666666667,
      })

      -- ░░░░░░░░░░  KEYBINDS  ░░░░░░░░░░

      hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("uwsm app -- kitty"))
      hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("uwsm app -- fuzzel"))
      hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
      hl.bind(mainMod .. " + SPACE",  hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
      hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd("loginctl lock-session"))
      hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
      hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(wlogout))

      hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(
          [[hyprctl eval '(function() for _, m in ipairs(hl.get_monitors()) do if m.name ~= "eDP-1" then local on = not m.is_mirror hl.monitor({ output = "desc:" .. m.description, mirror = on and "eDP-1" or "" }) if on then hl.exec_cmd("kanshictl switch extend") end end end end)()']]))

      -- Focus Navigation
      hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

      -- Window Movement within Tiling Tree
      hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
      hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
      hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
      hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

      -- Scratchpad Workspace
      hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("scratchpad"))
      hl.bind(mainMod .. " + ALT + S",   hl.dsp.window.move({ workspace = "special:scratchpad" }))

      -- Notification Center & Night Light
      hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd(swaync .. " -t -sw"))
      hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("hyprsunset-toggle"))

      -- Fuzzel Power Tools (NeoQWERTZ friendly: unshifted Layer 1 keys)
      hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("uwsm app -- fuzzel-calc"))
      hl.bind(mainMod .. " + I",         hl.dsp.exec_cmd("uwsm app -- fuzzel-keybinds"))
      hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd("audio-sink-toggle"))

      -- Clipboard History (Secure In-Memory Fuzzel UI)
      hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("uwsm app -- cliphist-fuzzel"))
      hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("uwsm app -- cliphist-wipe"))

      -- Layout Helpers (NeoQWERTZ friendly: Super+O for Orientation)
      hl.bind(mainMod .. " + O",         hl.dsp.exec_cmd("hyprctl dispatch togglesplit"))
      hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd("hyprctl dispatch pseudo"))

      -- Workspaces Navigation
      for i = 1, 10 do
          local key = i % 10
          hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
          hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- ░░░░░░░░░░  SCREENSHOTS  ░░░░░░░░░░

      hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(grim .. " -g \"$(" .. slurp .. ")\" - | " .. wlcopy))
      hl.bind("SHIFT + Print",           hl.dsp.exec_cmd(grim .. " -g \"$(" .. slurp .. ")\" - | " .. wlcopy))
      hl.bind("Print",                   hl.dsp.exec_cmd(grim .. " - | " .. wlcopy))

      -- ░░░░░░░░░░  MEDIA KEYS (SWAYOSD HUD)  ░░░░░░░░░░

      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(swayosd .. " --output-volume raise"), { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(swayosd .. " --output-volume lower"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(swayosd .. " --output-volume mute-toggle"), { locked = true, repeating = true })
      hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(swayosd .. " --input-volume mute-toggle"),  { locked = true, repeating = true })

      hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(swayosd .. " --brightness raise"), { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(swayosd .. " --brightness lower"), { locked = true, repeating = true })

      -- *:: to ignore the kernel-version dependent device name prefix
      hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd(brightnessctl .. " -d '*::kbd_backlight' set 33%+"), { locked = true, repeating = true })
      hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(brightnessctl .. " -d '*::kbd_backlight' set 33%-"), { locked = true, repeating = true })

      hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(playerctl .. " play-pause"), { locked = true })
      hl.bind("XF86AudioPause", hl.dsp.exec_cmd(playerctl .. " play-pause"), { locked = true })
      hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(playerctl .. " next"),       { locked = true })
      hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(playerctl .. " previous"),   { locked = true })

      hl.bind("XF86ScreenSaver", hl.dsp.exec_cmd("loginctl lock-session"))

      -- ░░░░░░░░░░ GESTURES  ░░░░░░░░░░

      hl.gesture({
        fingers = 3,
        direction = "horizontal",
        action = "workspace"
      })

      -- ░░░░░░░░░░  LAYER RULES  ░░░░░░░░░░

      hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
      hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0.2 })
      hl.layer_rule({ match = { namespace = "fuzzel" }, blur = true })
      hl.layer_rule({ match = { namespace = "wlogout" }, blur = true })
      hl.layer_rule({ match = { namespace = "swaync-control-center" }, blur = true })
      hl.layer_rule({ match = { namespace = "swayosd" }, blur = true })

      -- ░░░░░░░░░░  WINDOW RULES  ░░░░░░░░░░

      hl.window_rule({ match = { class = "firefox"  }, idle_inhibit = "fullscreen" })
      hl.window_rule({ match = { class = "chromium" }, idle_inhibit = "fullscreen" })
      hl.window_rule({ match = { class = "pinentry" }, float = true })
      hl.window_rule({ match = { class = "pinentry" }, pin   = true })
      hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
      hl.window_rule({ match = { class = "pavucontrol" }, float = true })
      hl.window_rule({ match = { title = "Volume Control" }, float = true })
      hl.window_rule({ match = { title = "Picture-in-Picture" }, float = true })
      hl.window_rule({ match = { title = "Picture-in-Picture" }, pin   = true })
      hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true })
      hl.window_rule({ match = { class = "kitty" }, tile = true })
      hl.window_rule({ match = { class = "org.gnome.Loupe" }, float = true })
      hl.window_rule({ match = { class = "org.gnome.Nautilus" }, float = true })
      hl.window_rule({ match = { class = "org.gnome.FileRoller" }, float = true })
    '';
  };
}
