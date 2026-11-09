{ pkgs, ... }:
let
  blankImg = pkgs.runCommand "blank.png" { } ''
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | ${pkgs.coreutils}/bin/base64 -d > $out
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
      STATUS_INFO="Charging"
    elif [ "$STATUS" = "Full" ]; then
      ICON="󰁹"
      ICON_COLOR="#a6e3a1"
      STATUS_INFO="Full"
    else
      if [ "$CAPACITY" -ge 95 ]; then ICON="󰁹"; ICON_COLOR="#a6e3a1"
      elif [ "$CAPACITY" -ge 80 ]; then ICON="󰂁"; ICON_COLOR="#a6e3a1"
      elif [ "$CAPACITY" -ge 60 ]; then ICON="󰁿"; ICON_COLOR="#cdd6f4"
      elif [ "$CAPACITY" -ge 40 ]; then ICON="󰁽"; ICON_COLOR="#cdd6f4"
      elif [ "$CAPACITY" -ge 25 ]; then ICON="󰁻"; ICON_COLOR="#fab387"
      elif [ "$CAPACITY" -ge 15 ]; then ICON="󰁺"; ICON_COLOR="#fab387"
      else ICON="󰂃"; ICON_COLOR="#f38ba8"
      fi
      STATUS_INFO=""
    fi

    if [ -n "$STATUS_INFO" ]; then
      echo "<span foreground='$ICON_COLOR'>$ICON</span>  <span weight='bold' foreground='#cdd6f4'>''${CAPACITY}%</span> <span size='small' foreground='#a6adc8'>($STATUS_INFO)</span>"
    else
      echo "<span foreground='$ICON_COLOR'>$ICON</span>  <span weight='bold' foreground='#cdd6f4'>''${CAPACITY}%</span>"
    fi
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
      echo "${blankImg}"
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

    echo "${blankImg}"
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

        # Time (Top-Right)
        {
          monitor = "";
          text = "$TIME";
          color = "$text";
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
          text = "cmd[update:60000] date +'%A, %d %B %Y'";
          color = "$subtext0";
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
