{ pkgs, ... }:
let
  # Antigravity IDE 2.6.0 - local package using callPackage
  antigravity-ide-2_6_0 = pkgs.callPackage ./antigravity-ide/package.nix { };
in
{
  home.packages = with pkgs; [
    antigravity-ide-2_6_0.passthru.fhs
  ];
}
