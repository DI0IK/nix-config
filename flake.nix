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

    hyprdynamicmonitors.url = "github:fiffeek/hyprdynamicmonitors";
  };

  outputs = { self, nixpkgs, disko, home-manager, sops-nix, impermanence, nixos-hardware, lanzaboote, hyprdynamicmonitors, ... }@inputs:
    let
      lib = nixpkgs.lib;

      mkHost = hostname: lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.framework-13-7040-amd
          sops-nix.nixosModules.sops
          impermanence.nixosModules.impermanence
          hyprdynamicmonitors.nixosModules.default

          ./hosts/common
          ./hosts/${hostname}

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.dominik = import ./home/dominik;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    in {
      nixosConfigurations.fw13 = mkHost "fw13";
    };
}