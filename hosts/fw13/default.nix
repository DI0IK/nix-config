{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ../shared/default.nix
    ../../modules/system/default.nix
  ];

  networking.hostName = "fw13";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  users.users.dominik = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    hashedPasswordFile = config.sops.secrets.dominik-password.path;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.dominik = import ../../home/dominik/default.nix;
    extraSpecialArgs = { inherit inputs; };
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

    secrets.dominik-password = {
      neededForUsers = true;
    };
  };

  fileSystems."/persist".neededForBoot = true;

  system.stateVersion = "26.05";

  virtualisation.vmVariant = {
    boot.initrd.secrets."/etc/ssh/ssh_host_ed25519_key" = ../../test_ssh_host_ed25519_key;
    environment.etc."ssh/ssh_host_ed25519_key".source = ../../test_ssh_host_ed25519_key;

    sops.age.sshKeyPaths = pkgs.lib.mkForce [ "/etc/ssh/ssh_host_ed25519_key" ];

    services.getty.autologinUser = pkgs.lib.mkForce "root";
  };
}