{ ... }: {
  imports = [
    ./firewall.nix
    ./apparmor.nix
    ./fprintd.nix
    ./sudo-run0.nix
    ./root-lock.nix
    ./kernel-hardening.nix
  ];
}
