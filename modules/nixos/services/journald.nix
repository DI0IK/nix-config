{ ... }:

{
  services.journald.extraConfig = ''
    SystemMaxUse=256M
    MaxRetentionSec=30day
    Storage=persistent
  '';
}
