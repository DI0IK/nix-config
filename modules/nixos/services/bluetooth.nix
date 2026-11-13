{ ... }: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  services.blueman.enable = true;

  # Needed for HFP/HSP (headset microphone) when security.lockKernelModules is enabled
  boot.kernelModules = [ "rfcomm" ];

  environment.persistence."/persist".directories = [
    "/var/lib/bluetooth/"
  ];
}
