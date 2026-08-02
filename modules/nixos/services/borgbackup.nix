{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.sshpass ];

  sops.secrets.borg-repo-passphrase = { };
  sops.secrets.borg-ssh-pass = {
    mode = "0400";
    owner = "root";
  };

  services.borgbackup.jobs."system" = {
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

    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets.borg-repo-passphrase.path}";
    };

    environment.BORG_RSH =
      "${pkgs.sshpass}/bin/sshpass -f ${config.sops.secrets.borg-ssh-pass.path}"
      + " ssh -o StrictHostKeyChecking=accept-new -p 23";

    compression = "zstd,3";
    startAt = "*:0/30";
    doInit = false;

    prune.keep = {
      within = "7d";
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
  };
}
