{ inputs, root }:
{ hostname
, system ? "x86_64-linux"
, users ? [ ]
, extraModules ? [ ]
}:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib;
  theme = import (root + "/modules/home/theme.nix");
in
lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };

  modules =
    (with inputs; [
      disko.nixosModules.disko
      lanzaboote.nixosModules.lanzaboote
      home-manager.nixosModules.home-manager
      sops-nix.nixosModules.sops
      impermanence.nixosModules.impermanence
    ])
    ++ [
      # Core NixOS module tree (boot, security, services, users, impermanence)
      (root + "/modules/nixos")

      # Theme available to all NixOS modules via module args
      { _module.args = { inherit theme; }; }

      # Host identity + overrides
      (root + "/hosts/${hostname}")

      # Home-manager for listed users
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs theme; };
          users = builtins.listToAttrs (map (u: {
            name = u;
            value = import (root + "/home/" + u);
          }) users);
        };
      }
    ]
    ++ extraModules;
}
