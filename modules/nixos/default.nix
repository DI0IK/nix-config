{ ... }: {
  # Theme available to all NixOS sub-modules via module args
  _module.args.theme = import ../home/theme.nix;

  imports = [
    ./boot
    ./security
    ./services
    ./users/users.nix
    ./impermanence.nix
  ];
}