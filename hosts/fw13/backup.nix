{ ... }:

{
  imports = [
    ../../modules/nixos/services/borgbackup.nix
  ];

  services.borgbackup.jobs.system = {
    paths = [
      "/persist/home/dominik/projects"
      "/persist/home/dominik/.config/Signal"
      "/persist/home/dominik/.thunderbird"
      "/persist/home/dominik/.librewolf"
      "/persist/home/dominik/.config/VSCodium"
      "/persist/home/dominik/.config/darktable"
    ];

    exclude = [
      "**/.cache/**"
      "**/Cache/**"
      "**/CachedData/**"

      "**/projects/**/node_modules/**"
      "**/projects/**/target/**"
      "**/projects/**/build/**"
      "**/projects/**/.devenv/**"
      "**/projects/**/.direnv/**"
    ];

    repo = "ssh://u599352-sub2@u599352-sub2.your-storagebox.de:23/./fw13";
  };
}