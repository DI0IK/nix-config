{ ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      dominik-password.neededForUsers = true;
      borg-repo-passphrase = { };
      borg-ssh-pass = { };
    };
  };
}
