{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/${config.networking.hostName}.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      dominik-password = {
        sopsFile = ../../secrets/common.yaml;
        neededForUsers = true;
      };
      borg-repo-passphrase = {
        sopsFile = ../../secrets/common.yaml;
      };
      borg-ssh-pass = {
        sopsFile = ../../secrets/common.yaml;
      };
    };
  };
}
