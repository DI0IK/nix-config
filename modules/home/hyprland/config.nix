{ pkgs, theme, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    package = null;
    portalPackage = null;

    settings = {
      "$mainMod" = "SUPER";

      general = {
        gaps_in = 2;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(${theme.green}aa)";
        "col.inactive_border" = "rgba(${theme.maroon}aa)";
      };

      decoration = {
        rounding = 5;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
      };

      animations = {
        enabled = true;
        bezier = [
          "overshoot, 0.05, 0.9, 0.1, 1.1"
        ];
        animation = [
          "windows, 1, 3.5, overshoot, popin 80%"
          "windowsIn, 1, 3, overshoot, popin 80%"
          "windowsOut, 1, 2.5, default, popin 80%"
          "fadeIn, 1, 3, default"
          "fadeOut, 1, 3, default"
          "workspaces, 1, 4.5, default, slide"
        ];
      };

      input = {
        kb_layout = "de";
        kb_variant = "neo_qwertz";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      bind = [
        "$mainMod, RETURN, exec, uwsm app -- kitty"
        "$mainMod, D, exec, uwsm app -- fuzzel"
        "$mainMod, Q, killactive,"
        "$mainMod, SPACE, togglefloating,"
        "$mainMod, F, fullscreen,"

        "$mainMod, T, exec, loginctl lock-session"
        "$mainMod SHIFT, E, exec, uwsm stop"

        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
      ];

      windowrulev2 = [
        "idleinhibit fullscreen, class:^(firefox)$"
        "idleinhibit fullscreen, class:^(chromium)$"

        "float, class:^(pinentry)"
        "pin, class:^(pinentry)"
      ];

      exec-once = [
        "uwsm app -- ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];
    };
  };
}
