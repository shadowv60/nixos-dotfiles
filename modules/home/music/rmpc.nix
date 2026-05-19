{ config, pkgs, ... }:

{
  home.packages = [ pkgs.rmpc ];

  # This links the local folder ./rmpc/ to ~/.config/rmpc/
  home.file.".config/rmpc".source = ./rmpc;

  services.mpd = {
    enable = true;
    musicDirectory = "/home/wolk/opus new";
    dataDir = "/home/wolk/.local/share/mpd";
    network.listenAddress = "127.0.0.1";
    network.port = 6600;
    extraConfig = ''
      auto_update "yes"
      restore_paused "yes"
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
      audio_output {
        type "fifo"
        name "cava_fifo"
        path "/tmp/mpd.fifo"
        format "44100:16:2"
      }
    '';
  };

  services.mpdris2.enable = true;
}
