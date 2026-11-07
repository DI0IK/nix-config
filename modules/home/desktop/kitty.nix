{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      remember_window_size = "no";
      initial_window_width = "850";
      initial_window_height = "500";
    };
  };
}
