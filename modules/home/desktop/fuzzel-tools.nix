{ pkgs, ... }:
let
  dropdownTerminal = pkgs.writeShellScriptBin "dropdown-terminal" ''
    set -euo pipefail
    if ! ${pkgs.hyprland}/bin/hyprctl clients | ${pkgs.gnugrep}/bin/grep -q "kitty-dropdown"; then
      uwsm app -- ${pkgs.kitty}/bin/kitty --class kitty-dropdown &
    fi
    ${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.workspace.toggle_special("dropdown")'
  '';

  fuzzelBluetooth = pkgs.writeShellScriptBin "fuzzel-bluetooth" ''
    set -euo pipefail

    BT_STATUS=$(${pkgs.bluez}/bin/bluetoothctl show | ${pkgs.gnugrep}/bin/grep -q "Powered: yes" && echo "on" || echo "off")

    if [ "$BT_STATUS" = "off" ]; then
      action=$(echo -e "󰂯 Turn Bluetooth On" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="󰂯    " --placeholder="Bluetooth is Off" -w 35)
      if [ -n "$action" ]; then
        ${pkgs.bluez}/bin/bluetoothctl power on
        ${pkgs.libnotify}/bin/notify-send "Bluetooth" "Bluetooth powered on" -i bluetooth
      fi
      exit 0
    fi

    devices=$(${pkgs.bluez}/bin/bluetoothctl devices Paired | cut -d ' ' -f 2- || true)

    menu="󰂲 Turn Bluetooth Off\n󰑐 Scan for devices"
    if [ -n "$devices" ]; then
      while IFS= read -r dev; do
        [ -z "$dev" ] && continue
        mac=$(echo "$dev" | awk '{print $1}')
        name=$(echo "$dev" | cut -d ' ' -f 2-)
        info=$(${pkgs.bluez}/bin/bluetoothctl info "$mac" || true)
        if echo "$info" | ${pkgs.gnugrep}/bin/grep -q "Connected: yes"; then
          menu+="\n󰂱 Disconnect $name ($mac)"
        else
          menu+="\n󰂯 Connect $name ($mac)"
        fi
      done <<< "$devices"
    fi

    chosen=$(echo -e "$menu" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="󰂯    " --placeholder="Select Bluetooth device..." -w 45 || true)
    [ -z "$chosen" ] && exit 0

    if [ "$chosen" = "󰂲 Turn Bluetooth Off" ]; then
      ${pkgs.bluez}/bin/bluetoothctl power off
      ${pkgs.libnotify}/bin/notify-send "Bluetooth" "Bluetooth powered off" -i bluetooth-disabled
    elif [ "$chosen" = "󰑐 Scan for devices" ]; then
      ${pkgs.libnotify}/bin/notify-send "Bluetooth" "Scanning for nearby devices..." -i bluetooth
      ${pkgs.bluez}/bin/bluetoothctl --timeout 10 scan on >/dev/null &
    elif [[ "$chosen" =~ Disconnect ]]; then
      mac=$(echo "$chosen" | ${pkgs.gnugrep}/bin/grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}')
      ${pkgs.bluez}/bin/bluetoothctl disconnect "$mac"
      ${pkgs.libnotify}/bin/notify-send "Bluetooth" "Disconnected $mac" -i bluetooth
    elif [[ "$chosen" =~ Connect ]]; then
      mac=$(echo "$chosen" | ${pkgs.gnugrep}/bin/grep -oE '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}')
      ${pkgs.libnotify}/bin/notify-send "Bluetooth" "Connecting to $mac..." -i bluetooth
      ${pkgs.bluez}/bin/bluetoothctl connect "$mac"
    fi
  '';

  fuzzelWifi = pkgs.writeShellScriptBin "fuzzel-wifi" ''
    set -euo pipefail

    ${pkgs.networkmanager}/bin/nmcli device wifi rescan 2>/dev/null || true

    networks=$(${pkgs.networkmanager}/bin/nmcli -t -f IN-USE,SSID,BARS,SECURITY device wifi list | ${pkgs.gawk}/bin/awk -F':' '
      $2 != "" {
        in_use = ($1 == "*") ? "󰤨 (connected) " : "󰤢 "
        sec = ($4 != "") ? " 󰌾" : ""
        print in_use $2 " [" $3 "]" sec
      }' | sort -u)

    chosen=$(echo -e "$networks" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="󰖩    " --placeholder="Select Wi-Fi Network..." -w 48 || true)
    [ -z "$chosen" ] && exit 0

    ssid=$(echo "$chosen" | ${pkgs.gnused}/bin/sed -E 's/^󰤨 \(connected\) //; s/^󰤢 //; s/ \[[^]]*\]( 󰌾)?$//')

    if echo "$chosen" | ${pkgs.gnugrep}/bin/grep -q "(connected)"; then
      action=$(echo -e "󰖪 Disconnect\n󰑐 Cancel" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="󰖩 $ssid: " -w 30 || true)
      if [ "$action" = "󰖪 Disconnect" ]; then
        ${pkgs.networkmanager}/bin/nmcli connection down id "$ssid" 2>/dev/null || ${pkgs.networkmanager}/bin/nmcli device disconnect wifi
        ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Disconnected from $ssid" -i network-wireless-disconnected
      fi
      exit 0
    fi

    if ${pkgs.networkmanager}/bin/nmcli connection show "$ssid" >/dev/null 2>&1; then
      ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Connecting to $ssid..." -i network-wireless
      if ${pkgs.networkmanager}/bin/nmcli connection up "$ssid"; then
        ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Connected to $ssid" -i network-wireless
      else
        ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Failed to connect to $ssid" -i dialog-error -u critical
      fi
    else
      if echo "$chosen" | ${pkgs.gnugrep}/bin/grep -q "󰌾"; then
        pass=$(${pkgs.fuzzel}/bin/fuzzel --dmenu --password --prompt="󰌾 Password: " --placeholder="Enter Wi-Fi password..." -w 35 || true)
        [ -z "$pass" ] && exit 0
        ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Connecting to $ssid..." -i network-wireless
        if ${pkgs.networkmanager}/bin/nmcli device wifi connect "$ssid" password "$pass"; then
          ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Connected to $ssid" -i network-wireless
        else
          ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Failed to connect to $ssid" -i dialog-error -u critical
        fi
      else
        ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Connecting to $ssid..." -i network-wireless
        if ${pkgs.networkmanager}/bin/nmcli device wifi connect "$ssid"; then
          ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Connected to $ssid" -i network-wireless
        else
          ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Failed to connect to $ssid" -i dialog-error -u critical
        fi
      fi
    fi
  '';

  fuzzelKeybinds = pkgs.writeShellScriptBin "fuzzel-keybinds" ''
        set -euo pipefail
        binds="Super + Return               Open Kitty terminal
    Super + -                    Toggle Quake dropdown terminal
    Super + D                    Open Fuzzel application launcher
    Super + V                    Browse in-memory clipboard history
    Super + Shift + V            Emergency clipboard wipe
    Super + B                    Quick Bluetooth device selector
    Super + W                    Quick Wi-Fi network selector
    Super + Shift + W            Windows Sandbox control menu
    Super + C                    Open live interactive calculator (qalc)
    Super + I                    Open this keybinding cheat sheet
    Super + A                    Toggle audio output (Speakers ⇄ Headphones)
    Super + Shift + N            Toggle night light (Hyprsunset 3500K ⇄ 6500K)
    Super + N                    Open notification center drawer (SwayNC)
    Super + Shift + Q            Close active window
    Super + Space                Toggle window floating mode
    Super + F                    Toggle window fullscreen mode
    Super + O                    Toggle layout split orientation
    Super + P                    Toggle pseudo-tiling mode
    Super + Shift + P            Wireless screen mirroring (Cast / Miracast)
    Super + H / J / K / L        Move focus left / down / up / right
    Super + Shift + H/J/K/L      Move window position in tiling tree
    Super + S                    Toggle scratchpad workspace
    Super + Alt + S              Move active window to scratchpad
    Super + 1..9                 Switch to workspace 1..9
    Super + Shift + 1..9         Move active window to workspace 1..9
    Super + Shift + S            Capture region screenshot to clipboard
    Print                        Capture full screen screenshot to clipboard
    Super + Escape               Open power menu (Wlogout)
    Super + T                    Lock session (Hyprlock)"

        echo "$binds" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="󰌌    " --placeholder="Search keybindings..." -w 65 >/dev/null || true
  '';

  audioSinkToggle = pkgs.writeShellScriptBin "audio-sink-toggle" ''
    set -euo pipefail
    sinks=($(${pkgs.wireplumber}/bin/wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '^[[:space:]]*[│*]? *[0-9]+\.' | awk '{print $2}' | tr -d '.'))
    if [ ''${#sinks[@]} -gt 1 ]; then
      current=$(${pkgs.wireplumber}/bin/wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -E '\*' | awk '{print $3}' | tr -d '.' || true)
      for i in "''${!sinks[@]}"; do
        if [ "''${sinks[$i]}" = "$current" ]; then
          next_idx=$(( (i + 1) % ''${#sinks[@]} ))
          target="''${sinks[$next_idx]}"
          ${pkgs.wireplumber}/bin/wpctl set-default "$target"
          sink_name=$(${pkgs.wireplumber}/bin/wpctl inspect "$target" | grep 'node.description' | cut -d'"' -f2 || echo "Audio Device $target")
          ${pkgs.libnotify}/bin/notify-send "Audio Output" "Switched to: $sink_name" -i audio-speakers
          exit 0
        fi
      done
    fi
    ${pkgs.libnotify}/bin/notify-send "Audio Output" "Only one audio output detected" -i audio-speakers -u low
  '';
  fuzzelWinSandbox = pkgs.writeShellScriptBin "fuzzel-win-sandbox" ''
    set -euo pipefail

    STATUS=$(win-sandbox status-brief 2>/dev/null || echo "stopped")

    case "$STATUS" in
      running)
        PROMPT="󰖳 Windows (Running): "
        MENU="⏸️ Pause VM\n🖥️ Focus / Show Viewer\n🛑 Power Off\n⚡ Force Kill\nℹ️ VM Status & Info"
        ;;
      paused)
        PROMPT="󰖳 Windows (Paused): "
        MENU="▶️ Resume VM\n🖥️ Show Viewer\n⚡ Force Kill\nℹ️ VM Status & Info"
        ;;
      *)
        PROMPT="󰖳 Windows (Stopped): "
        MENU="🚀 Start Disposable Session\n🛠️ Maintenance Mode (Save Changes)\nℹ️ VM Status & Info"
        ;;
    esac

    CHOSEN=$(echo -e "$MENU" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="$PROMPT" --placeholder="Select Windows Sandbox action..." -w 45 || true)
    [ -z "$CHOSEN" ] && exit 0

    case "$CHOSEN" in
      *"Start Disposable Session"*)
        uwsm app -- win-sandbox run &
        ;;
      *"Maintenance Mode"*)
        uwsm app -- win-sandbox edit &
        ;;
      *"Pause VM"*)
        win-sandbox pause
        ${pkgs.libnotify}/bin/notify-send "Windows Sandbox" "VM execution paused" -i media-playback-pause
        ;;
      *"Resume VM"*)
        win-sandbox resume
        ${pkgs.libnotify}/bin/notify-send "Windows Sandbox" "VM execution resumed" -i media-playback-start
        ;;
      *"Focus / Show Viewer"*|*"Show Viewer"*)
        win-sandbox view
        ;;
      *"Power Off"*)
        win-sandbox powerdown
        ${pkgs.libnotify}/bin/notify-send "Windows Sandbox" "Sent shutdown signal to Windows" -i system-shutdown
        ;;
      *"Force Kill"*)
        win-sandbox kill
        ${pkgs.libnotify}/bin/notify-send "Windows Sandbox" "VM terminated" -i process-stop -u critical
        ;;
      *"VM Status & Info"*)
        win-sandbox status | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="󰖳 Info: " -w 60 >/dev/null || true
        ;;
    esac
  '';

  waybarWinSandbox = pkgs.writeShellScriptBin "waybar-win-sandbox" ''
    set -euo pipefail

    STATUS=$(win-sandbox status-brief 2>/dev/null || echo "stopped")

    case "$STATUS" in
      running)
        echo '{"text":"󰖳","class":"running","tooltip":"Windows Sandbox: Running\n• Left-click: Pause\n• Right-click: Menu\n• Middle-click: Focus Viewer"}'
        ;;
      paused)
        echo '{"text":"󰏤","class":"paused","tooltip":"Windows Sandbox: Paused\n• Left-click: Resume\n• Right-click: Menu\n• Middle-click: Focus Viewer"}'
        ;;
      *)
        echo '{"text":""}'
        ;;
    esac
  '';
in
{
  home.packages = with pkgs; [
    libqalculate
    dropdownTerminal
    fuzzelBluetooth
    fuzzelWifi
    fuzzelKeybinds
    fuzzelWinSandbox
    waybarWinSandbox
    audioSinkToggle
  ];
}
