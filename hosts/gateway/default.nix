{ ... }:
{
  imports = [
    ./hardware.nix
    ./disk.nix
    ./backup.nix
    ../../modules/nixos/services/dns.nix
    ../../modules/nixos/services/journald.nix
    ../../modules/nixos/services/ssh.nix
    ../../modules/gateway
  ];

  networking.hostName = "gateway";
  networking.dnsOverTls = "1.1.1.1#one.one.one.one";

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.dominik.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNrhZ9q3SikMV7b7U/DqiGXAA3RO2lXlFX/Fgi8n2w2XQGhwRDzua1NaMwHNzjp2LFOz8tSlkB50RRp7HwFTjnIjKuIhn9hLSsdGmU5UhpnEeS1czO67E+e4bzzBqBX98xeALgNnzJJb68QGokEbvItVSVQP1zRAzEZqETM95ecbCm10gqMw7C7vHCFa1O+pVU3M31IhPZ/zscpSLFkPsbxTODgLn3sh75i+togN6zLtXfXfyz8ATIK2bibaaKu3s2n1Kvq9p+eUgzviGJcHuip8d+hNbiZhBnwTGiLCTa23ZzhO54G8DlOtUnpbAQlmERhHLaYSDKh2/UrGTmE09dExpRqounV0bZwrGNVBPe90xVku9XCbI5BjdXd0IkUzcHSaZMsehA0hCj7cvKTyrHp8N5SOOBJftK2XLJlMV0PhAUy1PD1R6SchdAWQO6/LJb4HETVLq99SS7AgJ1slw9GFUMC+YSI3q91STiat3Y/rAvmnCbQ0jc38g6YpF927Jhbi7+pMdMy0RDSeJ578WQ1dpzr4D9uGOXycW2Z3D33DseLrzHT8r+ps6TK0vTSJu2EEirMFzA0FcQ7pZfXer9FJx3l8VtxzT/JTzVmjkZ3h0tjKqsF4NndzFxB075tcSXMIEg+9smE5drT52dqqcvhzMobI5yzxLvastFiI7jUQ== openpgp:0x174207B6"
  ];

  gateway.wireguard = {
    enable = true;
    peers = [
      {
        name = "homelab";
        publicKey = "qLaTQ1iwBi5esETUZLbL+KS3VDd7eNBJon9TC9FmmSQ=";
        allowedIPs = [
          "172.30.32.2/32"
          "fd86:ea04:1115::2/128"
        ];
      }
      {
        name = "fw13";
        publicKey = "kpnkddOAO9MrErxZf1h/6ds0v/1pKQ035aJa8173zQ8=";
        allowedIPs = [
          "172.30.32.20/32"
          "fd86:ea04:1115::20/128"
        ];
      }
      {
        name = "handy";
        publicKey = "GW921GDog0Tc/tjfMfcv2rGuju70wU2WFN37ox85lxk=";
        allowedIPs = [
          "172.30.32.10/32"
          "fd86:ea04:1115::10/128"
        ];
      }
      {
        name = "tablet";
        publicKey = "Rod3l9yHpzSh8GKcPblv854r8l6TVy+i7FspuawwIVY=";
        allowedIPs = [
          "172.30.32.11/32"
          "fd86:ea04:1115::11/128"
        ];
      }
    ];
  };

  gateway.forwarding.enable = true;

  catppuccin = {
    enable = false;
    autoEnable = false;
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "26.05";
}
