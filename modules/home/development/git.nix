{ pkgs, ... }: {
  programs.git = {
    enable = true;
    settings.user.name = "Dominik Stahl";
    settings.user.email = "dominik@samdj.de";

    signing = {
      key = null;
      signByDefault = true;
    };
  };
}
