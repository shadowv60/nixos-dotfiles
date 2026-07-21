{ config, pkgs, ... }:

let
  # Replace this path with the absolute path to your local git dotfiles repository
  dotfilesDir = "/home/wolk/nixos-dotfiles";
in
{
  home.packages = [ pkgs.rmpc ];

  # Creates a mutable out-of-store symlink pointing directly to your local files
  home.file.".config/rmpc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/modules/home/music/rmpc";

  services.mpd = {
    enable = true;
    musicDirectory = "/home/wolk/Music";
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
