{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin-nix = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      sops-nix,
      impermanence,
      nixos-hardware,
      lanzaboote,
      nixpak,
      catppuccin-nix,
      authentik-nix,
      ...
    }@inputs:
    let
      root = toString ./.;
      mkHost = import ./lib/mkHost.nix { inherit inputs root; };
    in
    {
      nixosConfigurations = {
        fw13 = mkHost {
          hostname = "fw13";
          users = [ "dominik" ];
          extraModules = [
            inputs.nixos-hardware.nixosModules.framework-13-7040-amd
          ];
        };

        homelab = mkHost {
          hostname = "homelab";
          users = [ "dominik" ];
          extraModules = [
            authentik-nix.nixosModules.default
          ];
        };

        gateway = mkHost {
          hostname = "gateway";
          users = [ "dominik" ];
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
