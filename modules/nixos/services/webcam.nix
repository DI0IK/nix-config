{
  config,
  pkgs,
  lib,
  ...
}:

let
  gstPlugins = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    pkgs.pipewire
  ];

  sonyWebcamScript = pkgs.writeShellScriptBin "sony-webcam" ''
    set -euo pipefail

    export GST_PLUGIN_SYSTEM_PATH_1_0="${pkgs.lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins}"

    # Terminate any volume monitors holding PTP lock
    pkill -f gvfs-gphoto2-volume-monitor 2>/dev/null || true

    # Brief delay for USB/PTP device initialization when triggered via udev
    sleep 1

    echo "Detecting Sony camera connection..."
    RETRY=0
    while ! ${pkgs.gphoto2}/bin/gphoto2 --auto-detect | grep -qi "Sony"; do
      RETRY=$((RETRY + 1))
      if [ "$RETRY" -ge 5 ]; then
        echo "Error: Sony camera not detected by gphoto2." >&2
        echo "Check that:" >&2
        echo "  1. Camera is powered on and connected via USB data cable" >&2
        echo "  2. 'USB Connection' is set to 'PC Remote' in camera menu" >&2
        echo "  3. 'Ctrl w/ Smartphone' is set to 'Off' in camera menu" >&2
        exit 1
      fi
      sleep 1
    done

    echo "Streaming Sony a6400 to PipeWire (Video/Source)..."
    exec ${pkgs.gphoto2}/bin/gphoto2 --stdout --capture-movie \
      | ${pkgs.gst_all_1.gstreamer}/bin/gst-launch-1.0 -v \
          fdsrc ! \
          jpegdec ! \
          videoconvert ! \
          pipewiresink stream-properties='props,media.class=Video/Source,node.name="Sony a6400",node.description="Sony a6400"'
  '';
in
{
  # PTP camera udev rules & user permissions
  programs.gphoto2.enable = true;

  # Tools for camera streaming and inspection
  environment.systemPackages = with pkgs; [
    gphoto2
    sonyWebcamScript
  ];

  # Auto-start systemd service on camera connection
  systemd.services.sony-webcam = {
    description = "Sony a6400 PipeWire Virtual Webcam Stream";
    after = [ "network.target" "pipewire.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${sonyWebcamScript}/bin/sony-webcam";
      Restart = "no";
      User = "dominik";
      Group = "video";
      SupplementaryGroups = [ "camera" ];
      Environment = [
        "XDG_RUNTIME_DIR=/run/user/1000"
        "PIPEWIRE_RUNTIME_DIR=/run/user/1000"
      ];
    };
  };

  # Udev rules: trigger systemd service when Sony camera is connected
  services.udev.extraRules = ''
    # Sony ILCE-6400 / Sony Camera in PC Remote mode
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="0caa", TAG+="systemd", ENV{SYSTEMD_WANTS}+="sony-webcam.service"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{product}=="*ILCE*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="sony-webcam.service"
  '';
}
