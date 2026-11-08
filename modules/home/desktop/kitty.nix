{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      remember_window_size = "no";
      initial_window_width = "850";
      initial_window_height = "500";

      # Window geometry & padding
      window_padding_width = "12 16";
      confirm_os_window_close = 0;

      # Cursor physics & trail effects
      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 2;

      # Tab bar aesthetics
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Scrollback & rendering
      scrollback_lines = 10000;
      enable_audio_bell = false;
    };
  };
}
