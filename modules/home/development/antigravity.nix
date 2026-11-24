{ pkgs, ... }:
let
  # Antigravity App 2.33.0 - local package using callPackage
  antigravity-2_33_0 = pkgs.callPackage ./antigravity/package.nix { };
in
{
  home.packages = [ antigravity-2_33_0 pkgs.antigravity-cli ];
}
