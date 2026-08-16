{ ... }:

{
  imports = [
    ../../modules/nixos/services/borgbackup.nix
  ];

  services.borgbackup.jobs.system = {
    paths = [
      "/persist"
    ];

    exclude = [
      "**/.cache/**"
      "**/tmp/**"
      "**/cache/**"
    ];

    repo = "ssh://u599352-sub4@u599352-sub4.your-storagebox.de:23/./";
  };
}
