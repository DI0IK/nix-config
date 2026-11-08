{ pkgs, ... }:
{
  programs.spotify-player = {
    enable = true;
    settings = {
      client_id = "0a222f7f29d84f1798379240ac2fd658";
      # Disable ncspot fallback client so all endpoints use your verified Client ID
      ncspot_only_get_endpoints = [ ];
      theme = "Catppuccin-mocha";
      playback_window_position = "Top";
      cover_img_scale = 1.5;

      device = {
        name = "fw13";
        device_type = "computer";
        volume = 80;
        bitrate = 320;
        audio_cache = true;
        normalization = true;
      };

      copy_command = {
        command = "${pkgs.wl-clipboard}/bin/wl-copy";
        args = [ ];
      };
    };
  };

  # Prevent clobbering conflict if spotify-player created a default app.toml on first run
  xdg.configFile."spotify-player/app.toml".force = true;

  # Background daemon: provides persistent Spotify Connect receiver and continuous MPRIS
  systemd.user.services.spotify-player = {
    Unit = {
      Description = "Spotify Player Daemon";
      After = [ "graphical-session.target" "sound.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.spotify-player}/bin/spotify_player --daemon";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Desktop launcher entry for Fuzzel / application menus
  xdg.desktopEntries.spotify-player = {
    name = "Spotify";
    genericName = "Music Player";
    exec = "uwsm app -- kitty --class=spotify-player -e spotify_player";
    icon = "spotify";
    terminal = false;
    categories = [
      "Audio"
      "Music"
      "Player"
    ];
  };

  # Persist Spotify authentication and cache across impermanence boots
  home.persistence."/persist" = {
    directories = [
      ".config/spotify-player"
      ".cache/spotify-player"
    ];
  };
}
