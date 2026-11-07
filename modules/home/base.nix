{ ... }: {
  home.username = "dominik";
  home.homeDirectory = "/home/dominik";
  home.stateVersion = "26.05";

  home.file.".config/nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      permittedInsecurePackages = [
        "firefox-esr-140-bin-unwrapped-140.17.0esr"
      ];
    }
  '';
}
