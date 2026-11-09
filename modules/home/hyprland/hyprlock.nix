{ pkgs, ... }:
let
  blankImg = pkgs.runCommand "blank.png" { } ''
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | ${pkgs.coreutils}/bin/base64 -d > $out
  '';

  defaultArt = pkgs.runCommand "catppuccin-music.png" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
    rsvg-convert -w 72 -h 72 -f png -o $out << 'EOF'
    <svg width="72" height="72" viewBox="0 0 72 72" xmlns="http://www.w3.org/2000/svg">
      <rect width="72" height="72" rx="10" fill="#313244"/>
      <circle cx="36" cy="36" r="24" fill="#181825" stroke="#cba6f7" stroke-width="2"/>
      <circle cx="36" cy="36" r="16" fill="none" stroke="#45475a" stroke-width="0.8" stroke-dasharray="6,3"/>
      <circle cx="36" cy="36" r="11" fill="none" stroke="#45475a" stroke-width="0.8" stroke-dasharray="8,4"/>
      <circle cx="36" cy="36" r="7" fill="#313244"/>
      <circle cx="36" cy="36" r="2.5" fill="#cba6f7"/>
    </svg>
    EOF
  '';

  batteryScript = pkgs.writeShellScript "hyprlock-battery" ''
    set -euo pipefail

    BAT_DIR=""
    for b in /sys/class/power_supply/BAT*; do
      if [ -d "$b" ]; then
        BAT_DIR="$b"
        break
      fi
    done

    if [ -z "$BAT_DIR" ]; then
      exit 0
    fi

    CAPACITY=$(cat "$BAT_DIR/capacity" 2>/dev/null || echo 0)
    STATUS=$(cat "$BAT_DIR/status" 2>/dev/null || echo "Unknown")

    CHARGER_W=""
    CHARGER_PORT=""
    for u in /sys/class/power_supply/ucsi-source-psy-*; do
      if [ -d "$u" ] && [ "$(cat "$u/online" 2>/dev/null || echo 0)" = "1" ]; then
        V_U=$(cat "$u/voltage_now" 2>/dev/null || echo 0)
        I_U=$(cat "$u/current_now" 2>/dev/null || echo 0)
        if [ "$V_U" -gt 0 ] && [ "$I_U" -gt 0 ]; then
          W_INT=$(( (V_U / 1000) * (I_U / 1000) / 1000000 ))
          if [ "$W_INT" -gt 0 ]; then
            CHARGER_W="''${W_INT}W"
          fi
        fi
        PORT_ID="''${u##*:}"
        PORT_NUM="''${PORT_ID#0}"
        PORT_NUM="''${PORT_NUM#0}"
        CHARGER_PORT="Port $PORT_NUM"
        break
      fi
    done

    V_BAT=$(cat "$BAT_DIR/voltage_now" 2>/dev/null || echo 0)
    I_BAT=$(cat "$BAT_DIR/current_now" 2>/dev/null || echo 0)
    POWER_W=""
    if [ "$V_BAT" -gt 0 ] && [ "$I_BAT" -gt 0 ]; then
      POWER_W=$(${pkgs.gawk}/bin/awk -v v="$V_BAT" -v i="$I_BAT" 'BEGIN { printf "%.1f", (v * i) / 1000000000000 }')
    fi

    TIME_STR=""
    C_NOW=$(cat "$BAT_DIR/charge_now" 2>/dev/null || echo 0)
    C_FULL=$(cat "$BAT_DIR/charge_full" 2>/dev/null || echo 0)
    if [ "$I_BAT" -gt 0 ]; then
      if [ "$STATUS" = "Charging" ] && [ "$C_FULL" -gt "$C_NOW" ]; then
        DIFF=$((C_FULL - C_NOW))
        MINS=$(( (DIFF * 60) / I_BAT ))
        if [ "$MINS" -gt 0 ]; then
          H=$((MINS / 60))
          M=$((MINS % 60))
          if [ "$H" -gt 0 ]; then
            TIME_STR="''${H}h ''${M}m to full"
          else
            TIME_STR="''${M}m to full"
          fi
        fi
      elif [ "$STATUS" = "Discharging" ] && [ "$C_NOW" -gt 0 ]; then
        MINS=$(( (C_NOW * 60) / I_BAT ))
        if [ "$MINS" -gt 0 ]; then
          H=$((MINS / 60))
          M=$((MINS % 60))
          if [ "$H" -gt 0 ]; then
            TIME_STR="''${H}h ''${M}m left"
          else
            TIME_STR="''${M}m left"
          fi
        fi
      fi
    fi

    if [ "$STATUS" = "Charging" ]; then
      if [ "$CAPACITY" -ge 90 ]; then ICON="󰂅"
      elif [ "$CAPACITY" -ge 80 ]; then ICON="󰂄"
      elif [ "$CAPACITY" -ge 70 ]; then ICON="󰂋"
      elif [ "$CAPACITY" -ge 60 ]; then ICON="󰂊"
      elif [ "$CAPACITY" -ge 50 ]; then ICON="󰂉"
      elif [ "$CAPACITY" -ge 40 ]; then ICON="󰂈"
      elif [ "$CAPACITY" -ge 30 ]; then ICON="󰂇"
      elif [ "$CAPACITY" -ge 20 ]; then ICON="󰂆"
      else ICON="󰢝"
      fi
      ICON_COLOR="#a6e3a1"
    elif [ "$STATUS" = "Full" ]; then
      ICON="󰁹"
      ICON_COLOR="#a6e3a1"
    else
      if [ "$CAPACITY" -ge 95 ]; then ICON="󰁹"; ICON_COLOR="#a6e3a1"
      elif [ "$CAPACITY" -ge 80 ]; then ICON="󰂁"; ICON_COLOR="#a6e3a1"
      elif [ "$CAPACITY" -ge 60 ]; then ICON="󰁿"; ICON_COLOR="#cdd6f4"
      elif [ "$CAPACITY" -ge 40 ]; then ICON="󰁽"; ICON_COLOR="#cdd6f4"
      elif [ "$CAPACITY" -ge 25 ]; then ICON="󰁻"; ICON_COLOR="#fab387"
      elif [ "$CAPACITY" -ge 15 ]; then ICON="󰁺"; ICON_COLOR="#fab387"
      else ICON="󰂃"; ICON_COLOR="#f38ba8"
      fi
    fi

    EXTRA_PARTS=()
    if [ "$STATUS" = "Charging" ]; then
      [ -n "$POWER_W" ] && EXTRA_PARTS+=("+''${POWER_W}W")
      if [ -n "$CHARGER_W" ]; then
        if [ -n "$CHARGER_PORT" ]; then
          EXTRA_PARTS+=("''${CHARGER_W} PD ($CHARGER_PORT)")
        else
          EXTRA_PARTS+=("''${CHARGER_W} PD")
        fi
      fi
      [ -n "$TIME_STR" ] && EXTRA_PARTS+=("~$TIME_STR")
    elif [ "$STATUS" = "Full" ]; then
      EXTRA_PARTS+=("Full")
      [ -n "$CHARGER_W" ] && EXTRA_PARTS+=("''${CHARGER_W} plugged")
    else
      [ -n "$POWER_W" ] && EXTRA_PARTS+=("''${POWER_W}W")
      [ -n "$TIME_STR" ] && EXTRA_PARTS+=("~$TIME_STR")
    fi

    EXTRA_STR=""
    for item in "''${EXTRA_PARTS[@]}"; do
      EXTRA_STR="$EXTRA_STR · $item"
    done

    echo "<span foreground='$ICON_COLOR'>$ICON</span>  <span weight='bold' foreground='#cdd6f4'>''${CAPACITY}%</span><span size='small' foreground='#a6adc8'>$EXTRA_STR</span>"
  '';

  clockScript = pkgs.writeShellScript "hyprlock-clock" ''
    date +"<span weight='heavy' foreground='#cba6f7'>%H</span><span foreground='#6c7086'>:</span><span weight='heavy' foreground='#cdd6f4'>%M</span>"
  '';

  dateScript = pkgs.writeShellScript "hyprlock-date" ''
    date +"<span foreground='#b4befe'>󰃭</span>  <span weight='medium' foreground='#bac2de'>%A, %d %B %Y</span>"
  '';

  sysInfoScript = pkgs.writeShellScript "hyprlock-sysinfo" ''
    set -euo pipefail

    UP_SECS=$(${pkgs.gawk}/bin/awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)
    DAYS=$((UP_SECS / 86400))
    HOURS=$(( (UP_SECS % 86400) / 3600 ))
    MINS=$(( (UP_SECS % 3600) / 60 ))

    UPTIME_STR=""
    if [ "$DAYS" -gt 0 ]; then
      UPTIME_STR="''${DAYS}d ''${HOURS}h ''${MINS}m"
    elif [ "$HOURS" -gt 0 ]; then
      UPTIME_STR="''${HOURS}h ''${MINS}m"
    else
      UPTIME_STR="''${MINS}m"
    fi

    HOST="$(hostname 2>/dev/null || echo "fw13")"
    KERNEL="$(uname -r 2>/dev/null | cut -d'-' -f1 || echo "")"

    LEFT1=" NixOS"
    LEFT2="󱑂 up $UPTIME_STR"

    TARGET=16
    PAD1=$((TARGET - ''${#LEFT1}))
    PAD2=$((TARGET - ''${#LEFT2}))
    if [ "$PAD1" -lt 1 ]; then PAD1=1; fi
    if [ "$PAD2" -lt 1 ]; then PAD2=1; fi

    SPACES1=""
    for ((i=0; i<PAD1; i++)); do SPACES1+=" "; done
    SPACES2=""
    for ((i=0; i<PAD2; i++)); do SPACES2+=" "; done

    LINE1="<span foreground='#cba6f7'>$LEFT1</span>$SPACES1  <span foreground='#6c7086'>•</span>  <span weight='bold' foreground='#cdd6f4'>$HOST</span>"
    if [ -n "$KERNEL" ]; then
      LINE2="<span foreground='#a6adc8'>$LEFT2</span>$SPACES2  <span foreground='#6c7086'>•</span>  <span foreground='#bac2de'>Linux $KERNEL</span>"
    else
      LINE2="<span foreground='#a6adc8'>$LEFT2</span>"
    fi

    echo -e "<span allow_breaks='true'>$LINE1\n$LINE2</span>"
  '';

  mediaTextScript = pkgs.writeShellScript "hyprlock-media-text" ''
    set -euo pipefail

    STATUS="$(${pkgs.playerctl}/bin/playerctl status 2>/dev/null || true)"
    if [ "$STATUS" != "Playing" ] && [ "$STATUS" != "Paused" ]; then
      exit 0
    fi

    if [ "$STATUS" = "Playing" ]; then
      ICON="󰐊"
    else
      ICON="󰏤"
    fi

    TITLE="$(${pkgs.playerctl}/bin/playerctl metadata title 2>/dev/null || true)"
    ARTIST="$(${pkgs.playerctl}/bin/playerctl metadata artist 2>/dev/null || true)"
    ALBUM="$(${pkgs.playerctl}/bin/playerctl metadata album 2>/dev/null || true)"

    if [ -z "$TITLE" ]; then
      exit 0
    fi

    escape_pango() {
      echo "$1" | ${pkgs.gnused}/bin/sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
    }

    truncate() {
      local text="$1"
      local max="$2"
      if [ ''${#text} -gt "$max" ]; then
        echo "''${text:0:$((max - 1))}…"
      else
        echo "$text"
      fi
    }

    TITLE_CLEAN=$(escape_pango "$(truncate "$TITLE" 40)")
    ARTIST_CLEAN=$(escape_pango "$(truncate "$ARTIST" 30)")
    ALBUM_CLEAN=$(escape_pango "$(truncate "$ALBUM" 30)")

    SUBTEXT="$ARTIST_CLEAN"
    if [ -n "$ALBUM_CLEAN" ]; then
      SUBTEXT="$ARTIST_CLEAN  ·  <i>$ALBUM_CLEAN</i>"
    fi

    POS_RAW="$(${pkgs.playerctl}/bin/playerctl position 2>/dev/null || echo 0)"
    LEN_RAW="$(${pkgs.playerctl}/bin/playerctl metadata mpris:length 2>/dev/null || echo 0)"
    POS="''${POS_RAW%%.*}"
    POS="''${POS:-0}"
    LEN=$((LEN_RAW / 1000000))

    PROGRESS_LINE=""
    if [ "$LEN" -gt 0 ] && [ "$POS" -ge 0 ]; then
      if [ "$POS" -gt "$LEN" ]; then POS="$LEN"; fi
      POS_STR=$(printf "%d:%02d" $((POS / 60)) $((POS % 60)))
      LEN_STR=$(printf "%d:%02d" $((LEN / 60)) $((LEN % 60)))

      BAR_WIDTH=16
      FILLED=$((POS * (BAR_WIDTH - 1) / LEN))
      EMPTY=$((BAR_WIDTH - 1 - FILLED))

      FILLED_STR=""
      EMPTY_STR=""
      for ((i=0; i<FILLED; i++)); do FILLED_STR+="━"; done
      for ((i=0; i<EMPTY; i++)); do EMPTY_STR+="━"; done

      PROGRESS_LINE="\n<span size='small' foreground='#a6adc8'>$POS_STR </span><span foreground='#cba6f7'>$FILLED_STR</span><span foreground='#f5e0dc'>●</span><span foreground='#45475a'>$EMPTY_STR</span><span size='small' foreground='#a6adc8'> $LEN_STR</span>"
    fi

    echo -e "<span allow_breaks='true'><span foreground='#cba6f7'>$ICON  </span><span weight='bold' foreground='#cdd6f4'>$TITLE_CLEAN</span>\n<span size='small' foreground='#a6adc8'>$SUBTEXT</span>$PROGRESS_LINE</span>"
  '';

  mediaArtScript = pkgs.writeShellScript "hyprlock-media-art" ''
    set -euo pipefail

    STATUS="$(${pkgs.playerctl}/bin/playerctl status 2>/dev/null || true)"
    if [ "$STATUS" != "Playing" ] && [ "$STATUS" != "Paused" ]; then
      echo "${blankImg}"
      exit 0
    fi

    ART_URL="$(${pkgs.playerctl}/bin/playerctl metadata mpris:artUrl 2>/dev/null || true)"
    if [ -z "$ART_URL" ]; then
      echo "${defaultArt}"
      exit 0
    fi

    if [[ "$ART_URL" == file://* ]]; then
      LOCAL_PATH="''${ART_URL#file://}"
      if [ -f "$LOCAL_PATH" ]; then
        echo "$LOCAL_PATH"
        exit 0
      fi
    elif [[ "$ART_URL" =~ ^https?:// ]]; then
      RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/tmp}/hyprlock-media"
      mkdir -p "$RUNTIME_DIR"
      TEMP_IMG="$RUNTIME_DIR/temp_cover"
      COVER_IMG="$RUNTIME_DIR/cover.png"
      if ${pkgs.curl}/bin/curl -s -f --connect-timeout 2 --max-time 3 "$ART_URL" -o "$TEMP_IMG" 2>/dev/null; then
        mv "$TEMP_IMG" "$COVER_IMG"
        echo "$COVER_IMG"
        exit 0
      fi
    fi

    echo "${defaultArt}"
  '';
in
{
  catppuccin.hyprlock.useDefaultConfig = false;

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        grace = 0;
        no_fade_in = false;
      };

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
        }
      ];

      image = [
        {
          monitor = "";
          path = "$HOME/.face";
          size = 100;
          rounding = -1;
          border_size = 3;
          border_color = "$accent";
          position = "0, 75";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 4;
          shadow_color = "rgba(0, 0, 0, 0.3)";
        }
        {
          monitor = "";
          path = "${blankImg}";
          size = 72;
          rounding = 8;
          border_size = 0;
          reload_time = 2;
          reload_cmd = "${mediaArtScript}";
          position = "40, 40";
          halign = "left";
          valign = "bottom";
        }
      ];

      label = [
        # Keyboard Layout (Top-Left)
        {
          monitor = "";
          text = "<span foreground='##$accentAlpha'>󰌌 </span> <span weight='bold' foreground='##$textAlpha'>$LAYOUT</span>";
          font_size = 13;
          font_family = "JetBrainsMono Nerd Font";
          position = "40, -35";
          halign = "left";
          valign = "top";
          shadow_passes = 1;
          shadow_size = 3;
          shadow_color = "rgba(0, 0, 0, 0.5)";
        }

        # Battery Status (Top-Left, below layout)
        {
          monitor = "";
          text = "cmd[update:5000] ${batteryScript}";
          font_size = 12;
          font_family = "JetBrainsMono Nerd Font";
          position = "40, -66";
          halign = "left";
          valign = "top";
          shadow_passes = 1;
          shadow_size = 3;
          shadow_color = "rgba(0, 0, 0, 0.5)";
        }

        # Time (Top-Right, Duotone Clock)
        {
          monitor = "";
          text = "cmd[update:1000] ${clockScript}";
          font_size = 80;
          font_family = "JetBrainsMono Nerd Font";
          position = "-40, -20";
          halign = "right";
          valign = "top";
          shadow_passes = 2;
          shadow_size = 4;
          shadow_color = "rgba(0, 0, 0, 0.4)";
        }

        # Date (Top-Right, below time)
        {
          monitor = "";
          text = "cmd[update:60000] ${dateScript}";
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font";
          position = "-40, -145";
          halign = "right";
          valign = "top";
          shadow_passes = 1;
          shadow_size = 2;
          shadow_color = "rgba(0, 0, 0, 0.4)";
        }

        # Fingerprint Prompt (Center, below input)
        {
          monitor = "";
          text = "$FPRINTPROMPT";
          color = "$text";
          font_size = 14;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -107";
          halign = "center";
          valign = "center";
          shadow_passes = 1;
          shadow_size = 2;
          shadow_color = "rgba(0, 0, 0, 0.4)";
        }

        # Media Player (Bottom-Left)
        {
          monitor = "";
          text = "cmd[update:1000] ${mediaTextScript}";
          font_size = 12;
          font_family = "JetBrainsMono Nerd Font";
          position = "126, 38";
          halign = "left";
          valign = "bottom";
        }

        # System Info HUD (Bottom-Right)
        {
          monitor = "";
          text = "cmd[update:10000] ${sysInfoScript}";
          font_size = 12;
          font_family = "JetBrainsMono Nerd Font";
          text_align = "left";
          position = "-40, 38";
          halign = "right";
          valign = "bottom";
          shadow_passes = 1;
          shadow_size = 3;
          shadow_color = "rgba(0, 0, 0, 0.5)";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 55";
          outline_thickness = 3;
          dots_size = 0.22;
          dots_spacing = 0.25;
          dots_center = true;
          outer_color = "$accent";
          inner_color = "$surface0";
          font_color = "$text";
          fade_on_empty = false;
          placeholder_text = "<span foreground='##$textAlpha'><i>󰌾 Logged in as </i><span foreground='##$accentAlpha'>$USER</span></span>";
          hide_input = false;
          check_color = "$accent";
          fail_color = "$red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = "$yellow";
          position = "0, -47";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 4;
          shadow_color = "rgba(0, 0, 0, 0.3)";
        }
      ];

      auth = {
        fingerprint = {
          enabled = true;
          ready_message = "Scan fingerprint to unlock";
          present_message = "Scanning...";
          retry_delay = 250;
        };
      };
    };
  };
}
