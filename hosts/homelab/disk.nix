{
  disks ? [ "/dev/vda" ],
  ...
}:

{
  disko.devices = {
    disk = {
      system = {
        type = "disk";
        device = builtins.elemAt disks 0;

        content = {
          type = "gpt";

          partitions = {
            ESP = {
              name = "ESP";
              size = "1G";
              type = "EF00";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";

                mountOptions = [
                  "umask=0077"
                ];
              };
            };

            root = {
              name = "root";
              size = "100%";

              content = {
                type = "btrfs";

                extraArgs = [
                  "-f"
                  "-L"
                  "nixos"
                ];

                subvolumes = {
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };

    nodev = {
      "/" = {
        type = "nodev";
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=2G"
          "mode=755"
        ];
      };
    };
  };
}
