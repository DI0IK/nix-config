{ inputs, root }:
{ hostname
, system ? "x86_64-linux"
, users ? [ ]
, extraModules ? [ ]
}:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib;
  theme = import (root + "/modules/shared/theme.nix");
  homeUsers = builtins.listToAttrs (map (name: {
    inherit name;
    value = import (root + "/home/${name}/${hostname}.nix");
  }) users);
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
      catppuccin-nix.nixosModules.catppuccin
      hyprdynamicmonitors.nixosModules.default
    ])
    ++ [
      # Core NixOS module tree (boot, security, users, impermanence)
      (root + "/modules/nixos")

      # Theme available to all NixOS modules via module args
      { _module.args = { inherit theme; }; }

      # Host identity + overrides
      (root + "/hosts/${hostname}")

      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs theme; };
          sharedModules = [ inputs.impermanence.homeManagerModules.impermanence ];
          users = homeUsers;
        };
      }
    ]
    ++ extraModules;
}
