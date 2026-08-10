{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yt-dlp
    jq
    ffmpeg
    (python3.withPackages (ps: [ ps.mutagen ps.ytmusicapi ]))
  ];

  programs.fish.functions = {
    dlmusic = ''
      set url $argv[1]

      set output (yt-dlp \
          --no-simulate \
          --extract-audio \
          --audio-format opus \
          --audio-quality 0 \
          --embed-thumbnail \
          --embed-metadata \
          --write-thumbnail \
          --convert-thumbnails jpg \
          --print "after_move:%(filepath)s|%(artist,uploader)s|%(album,playlist_title,webpage_url_domain)s|%(title)s" \
          --output "%(artist,uploader)s/%(album,playlist_title,webpage_url_domain)s/%(title)s.%(ext)s" \
          $url)

      echo $output | read -d "|" opus_path artist album title

      set clean_title (echo $title | sed 's/([^)]*)//g' | string trim)
      set lrc_path (string replace -r '\.[^.]+$' '.lrc' $opus_path)
      set query (string replace -a " " "+" "$clean_title $artist")

      set lyrics (curl -s "https://lrclib.net/api/search?q=$query" | jq -r '.[0].syncedLyrics // .[0].plainLyrics // empty')

      if test -n "$lyrics"
          printf "[ti:%s]\n[ar:%s]\n[al:%s]\n" $title $artist $album > $lrc_path
          string join \n $lyrics >> $lrc_path
          python3 -c "
from mutagen.oggopus import OggOpus
audio = OggOpus('$opus_path')
audio['lyrics'] = [open('$lrc_path').read()]
audio.save()
"
          echo "✓ Lyrics saved and embedded for $clean_title"
      else
          echo "✗ No lyrics found for $clean_title"
      end
    '';
  };
}
