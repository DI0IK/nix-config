{
  pkgs,
  ...
}:
{
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        width = 50;
        terminal = "${pkgs.kitty}/bin/kitty";
      };
    };
  };
}
