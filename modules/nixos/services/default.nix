{ ... }: {
  imports = [
    ./audio.nix
    ./borgbackup.nix
    ./display.nix
    ./bluetooth.nix
    ./virtualisation.nix
    ./dns.nix
    ./vpn.nix
    ./snapshots.nix
    ./gpg.nix
  ];
}
