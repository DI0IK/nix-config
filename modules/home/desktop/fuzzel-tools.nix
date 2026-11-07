{ pkgs, ... }:
let
  dropdownTerminal = pkgs.writeShellScriptBin "dropdown-terminal" ''
    set -euo pipefail
    if ! ${pkgs.hyprland}/bin/hyprctl clients | ${pkgs.gnugrep}/bin/grep -q "kitty-dropdown"; then
      uwsm app -- ${pkgs.kitty}/bin/kitty --class kitty-dropdown &
    fi
    ${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.workspace.toggle_special("dropdown")'
  '';

  fuzzelKeybinds = pkgs.writeShellScriptBin "fuzzel-keybinds" ''
        set -euo pipefail
        binds="Super + Return               Open Kitty terminal
    Super + -                    Toggle Quake dropdown terminal
    Super + D                    Open Fuzzel application launcher
    Super + V                    Browse in-memory clipboard history
    Super + Shift + V            Emergency clipboard wipe
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
in
{
  home.packages = with pkgs; [
    libqalculate
    dropdownTerminal
    fuzzelKeybinds
    audioSinkToggle
  ];
}
