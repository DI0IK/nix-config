{ ... }: {
  imports = [
    ./kernel.nix
    ./secure-boot.nix
    ./plymouth.nix
  ];
}