{ pkgs, ... }:
let
  # Antigravity App 2.29.0 - local package using callPackage
  antigravity-2_29_0 = pkgs.callPackage ./antigravity/package.nix { };
in
{
  home.packages = with pkgs; [
    antigravity-2_29_0.passthru.fhs
  ];
}
