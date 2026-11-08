{ pkgs, ... }:
let
  blankImg = pkgs.runCommand "blank.png" { } ''
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" | ${pkgs.coreutils}/bin/base64 -d > $out
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

    echo -e "<span allow_breaks='true'><span foreground='#cba6f7'>$ICON  </span><span weight='bold' foreground='#cdd6f4'>$TITLE_CLEAN</span>\n<span size='small' foreground='#a6adc8'>$SUBTEXT</span></span>"
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
        {
          monitor = "";
          text = "cmd[update:2000] ${mediaTextScript}";
          font_size = 12;
          font_family = "JetBrainsMono Nerd Font";
          position = "126, 43";
          halign = "left";
          valign = "bottom";
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
