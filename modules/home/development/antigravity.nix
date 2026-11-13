{ pkgs, ... }:
let
  # Antigravity App 2.31.2 - local package using callPackage
  antigravity-2_31_2 = pkgs.callPackage ./antigravity/package.nix { };
in
{
  home.packages = with pkgs; [
    antigravity-2_31_2.passthru.fhs
  ];
}
