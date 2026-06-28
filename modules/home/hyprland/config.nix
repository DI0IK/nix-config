{ pkgs, lib, theme, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = false;
    package = null;
    portalPackage = null;

    settings = { };

    extraConfig = ''
      local mainMod = "SUPER"

      hl.env("XCURSOR_THEME", "Adwaita")
      hl.env("XCURSOR_SIZE", "18")
      hl.env("HYPRCURSOR_THEME", "Adwaita")
      hl.env("HYPRCURSOR_SIZE", "18")

      -- ░░░░░░░░░░  LOOK AND FEEL  ░░░░░░░░░░

      hl.config({
          general = {
              gaps_in       = 2,
              gaps_out      = 10,
              border_size   = 2,
              col = {
                  active_border   = "rgba(${lib.strings.removePrefix "#" theme.green}aa)",
                  inactive_border = "rgba(${lib.strings.removePrefix "#" theme.maroon}aa)",
              },
          },
          decoration = {
              rounding          = 5,
              rounding_power    = 2,
              active_opacity    = 1.0,
              inactive_opacity  = 1.0,
          },
          animations = {
              enabled = true,
          },
          misc = {
            force_default_wallpaper = -1,
            disable_hyprland_logo = true,
          },
          xwayland = {
            enabled = false,
          }
      })

      hl.curve("overshoot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.1} } })

      hl.animation({ leaf = "windows",       enabled = true, speed = 3.5, bezier = "overshoot", style = "popin 80%" })
      hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3,   bezier = "overshoot", style = "popin 80%" })
      hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.5, bezier = "default",   style = "popin 80%" })
      hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3,   bezier = "default" })
      hl.animation({ leaf = "fadeOut",       enabled = true, speed = 3,   bezier = "default" })
      hl.animation({ leaf = "workspaces",    enabled = true, speed = 4.5, bezier = "default",   style = "slide" })

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

      -- ░░░░░░░░░░  KEYBINDS  ░░░░░░░░░░

      hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("uwsm app -- kitty"))
      hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("uwsm app -- fuzzel"))
      hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.window.close())
      hl.bind(mainMod .. " + SPACE",  hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen())
      hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd("loginctl lock-session"))
      hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))

      hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

      for i = 1, 10 do
          local key = i % 10
          hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
          hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      -- ░░░░░░░░░░  GESTURES  ░░░░░░░░░░

      hl.gesture({
        fingers = 3,
        direction = "horizontal",
        action = "workspace"
      })

      -- ░░░░░░░░░░  WINDOW RULES  ░░░░░░░░░░

      hl.window_rule({ match = { class = "firefox"  }, idle_inhibit = "fullscreen" })
      hl.window_rule({ match = { class = "chromium" }, idle_inhibit = "fullscreen" })
      hl.window_rule({ match = { class = "pinentry" }, float = true })
      hl.window_rule({ match = { class = "pinentry" }, pin   = true })

      -- ░░░░░░░░░░  AUTOSTART  ░░░░░░░░░░

      hl.on("hyprland.start", function()
          hl.exec_cmd("uwsm app -- ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent")
      end)
    '';
  };
}
