{ pkgs, theme, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        grace = 0;
        no_fade_in = false;
      };

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
        }
      ];

      auth = {
        fingerprint = {
          enabled = true;
          ready_message = "Scan fingerprint to unlock";
          present_message = "Scanning...";
          retry_delay = 250;
        };
      };

      input-field = [
        {
          monitor = "";
          size = "250, 60";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba(${theme.blue}, 1.0)";
          inner_color = "rgba(${theme.base}, 1.0)";
          font_color = "rgba(${theme.text}, 1.0)";
          fade_on_empty = false;
          placeholder_text = "<i>Password or fingerprint...</i>";
          fail_text = "$PAMFAIL$FPRINTFAIL";
          hide_input = false;
          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "$FPRINTPROMPT";
          color = "rgba(${theme.subtext0}, 1.0)";
          font_size = 14;
          position = "0, -90";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
