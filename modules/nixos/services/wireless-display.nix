{ pkgs, ... }:

{
  # GNOME Network Displays: Miracast (Wi-Fi Display) and Google Cast (Chromecast)
  # The package automatically bundles its required GStreamer runtime plugins.
  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];

  # Avahi daemon for mDNS / DNS-SD (zero-configuration networking)
  # Essential for discovering Google Cast and Miracast over Infrastructure (MICE) displays on the local Wi-Fi.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Network ports and trusted interfaces for wireless screen mirroring
  networking.firewall = {
    # 7236 = Miracast RTSP control channel; 7250 = Miracast alternate RTSP
    allowedTCPPorts = [
      7236
      7250
    ];

    # 5353 = mDNS service discovery; 7236 = Miracast control/status
    allowedUDPPorts = [
      5353
      7236
    ];

    # Trust virtual Wi-Fi Direct peer-to-peer interfaces
    trustedInterfaces = [
      "p2p-wl+"
      "p2p-+"
    ];
  };
}
