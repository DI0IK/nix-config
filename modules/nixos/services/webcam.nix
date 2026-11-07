{
  config,
  pkgs,
  lib,
  ...
}:

let
  sonyWebcamScript = pkgs.writeShellScriptBin "sony-webcam" ''
    set -euo pipefail

    echo "==> Searching for Sony a6400 v4l2loopback device..."
    VIDEO_DEV=""

    # Find loopback device matching card label
    for dev in /sys/devices/virtual/video4linux/video*; do
      if [ -d "$dev" ] && grep -qi "Sony a6400" "$dev/name" 2>/dev/null; then
        VIDEO_DEV="/dev/$(basename "$dev")"
        break
      fi
    done

    if [ -z "$VIDEO_DEV" ]; then
      # Fallback to any v4l2loopback device
      for dev in /sys/devices/virtual/video4linux/video*; do
        if [ -d "$dev" ] && grep -qi "v4l2loopback" "$dev/name" 2>/dev/null; then
          VIDEO_DEV="/dev/$(basename "$dev")"
          break
        fi
      done
    fi

    if [ -z "$VIDEO_DEV" ]; then
      echo "Error: Virtual loopback video device not found." >&2
      echo "Please ensure the 'v4l2loopback' module is loaded (a reboot may be required)." >&2
      exit 1
    fi

    echo "Found virtual webcam device: $VIDEO_DEV"

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

    echo "Streaming Sony a6400 to $VIDEO_DEV..."
    exec ${pkgs.gphoto2}/bin/gphoto2 --stdout --capture-movie \
      | ${pkgs.ffmpeg}/bin/ffmpeg -hide_banner -loglevel error \
          -fflags nobuffer -flags low_delay \
          -i - \
          -vcodec rawvideo -pix_fmt yuv420p -threads 0 \
          -f v4l2 "$VIDEO_DEV"
  '';
in
{
  # Kernel module packages and loading at boot (required for locked kernel modules)
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];

  # Configure loopback device
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 card_label="Sony a6400" max_buffers=2
  '';

  # PTP camera udev rules & user permissions
  programs.gphoto2.enable = true;

  # Tools for camera streaming and inspection
  environment.systemPackages = with pkgs; [
    v4l-utils
    gphoto2
    ffmpeg
    sonyWebcamScript
  ];

  # Auto-start systemd service on camera connection
  systemd.services.sony-webcam = {
    description = "Sony a6400 USB Webcam Stream";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${sonyWebcamScript}/bin/sony-webcam";
      Restart = "no";
      User = "dominik";
      Group = "video";
      SupplementaryGroups = [ "camera" ];
    };
  };

  # Udev rules: trigger systemd service when Sony camera is connected
  services.udev.extraRules = ''
    # Sony ILCE-6400 / Sony Camera in PC Remote mode
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="0caa", TAG+="systemd", ENV{SYSTEMD_WANTS}+="sony-webcam.service"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{product}=="*ILCE*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="sony-webcam.service"
  '';
}
