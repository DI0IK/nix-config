{ ... }:
{
  services.logind.settings = {
    Login = {
      # Power button
      HandlePowerKey = "suspend";
      HandlePowerKeyLongPress = "poweroff";

      # Lid switch
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";

      # Backpack safety: don't let background media/apps prevent suspend on lid close
      LidSwitchIgnoreInhibited = "yes";
    };
  };
}
