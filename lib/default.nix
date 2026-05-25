{ lib }:

# Re-export nixpkgs lib, extended with custom helpers as needed
lib.extend (final: prev: {
  # mkHost is consumed directly by flake.nix, not via this re-export
})
