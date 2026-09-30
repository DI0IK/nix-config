{ ... }:
let
  # 2256x1504 at this scale is 1440x960 logical, exact 3:2 so no letterboxing.
  laptopScale = 1.5666666666666667;

  # kanshi matches on "<make> <model> <serial>", not on the description.
  dock = "Acer Technologies ED273 T9DEE0133900";

  laptopOutput = {
    criteria = "eDP-1";
    status = "enable";
    mode = "2256x1504@60.00Hz";
    position = "0,0";
    scale = laptopScale;
  };
in
{
  services.kanshi = {
    enable = true;

    # First match wins, so docked has to stay ahead of extend. extend also
    # covers mirroring: Hyprland forces a mirror onto its source's position and
    # wlr-output-management cannot express the mirror relation itself.
    settings = [
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = dock;
            status = "enable";
            mode = "preferred";
            position = "0,0";
            scale = 1.0;
          }
        ];
      }

      {
        profile.name = "undocked";
        profile.outputs = [ laptopOutput ];
      }

      {
        profile.name = "extend";
        profile.outputs = [
          laptopOutput
          {
            criteria = "*";
            status = "enable";
            mode = "preferred";
            position = "1440,0";
            scale = 1.0;
          }
        ];
      }
    ];
  };
}
