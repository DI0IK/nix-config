{ ... }:

{
  imports = [
    ../../modules/nixos/services/borgbackup.nix
  ];

  services.borgbackup.jobs.system = {
    paths = [
      "/persist/apps"
    ];

    exclude = [
      "**/.cache/**"
      "**/tmp/**"
      "**/cache/**"
    ];

    repo = "ssh://u599352-sub3@u599352-sub3.your-storagebox.de:23/./";
  };
}
