{ pkgs, ... }:
{
  programs.fish.functions = {
    _convertflac_one = ''
      set flac $argv[1]
      set bitrate $argv[2]
      set opus (string replace -r '\.flac$' '.opus' -- $flac)
      set cover (mktemp --suffix=.jpg)

      ffmpeg -y -i "$flac" -an -vcodec copy "$cover" -v quiet 2>/dev/null

      if test -s "$cover"
          if opusenc --bitrate $bitrate --picture "$cover" --quiet "$flac" "$opus"
              touch -r "$flac" "$opus"
          else
              echo "Error: $flac"
          end
      else
          if opusenc --bitrate $bitrate --quiet "$flac" "$opus"
              touch -r "$flac" "$opus"
          else
              echo "Error: $flac"
          end
      end

      rm -f "$cover"

      set lyrics_status (env FLAC="$flac" OPUS="$opus" python3 -c "
import os, re
from mutagen.flac import FLAC
from mutagen.oggopus import OggOpus

src = FLAC(os.environ['FLAC'])
dst = OggOpus(os.environ['OPUS'])

def get(tags, keys):
    for k in keys:
        if k in tags:
            return tags[k][0]
    return None

synced = get(src, ('syncedlyrics', 'SYNCEDLYRICS'))
plain = get(src, ('lyrics', 'LYRICS'))

has_timestamps = bool(synced and re.search(r'\[\d{2}:\d{2}', synced))

if has_timestamps:
    dst['LYRICS'] = synced
    dst['SYNCEDLYRICS'] = synced
    print('HAS_SYNCED')
else:
    if plain:
        dst['LYRICS'] = plain
    print('NO_SYNCED')

dst.save()
")

      echo "🎵 $opus: $lyrics_status"

      if test "$lyrics_status" = "NO_SYNCED"
          addlyrics "$opus"
      end
    '';

    convertflac = ''
      set bitrate 160
      if test (count $argv) -gt 0
          set bitrate $argv[1]
      end

      for f in *.flac
          printf '%s\0' "fish -c '_convertflac_one \"$f\" $bitrate'"
      end | parallel -0 --progress -j (nproc)
    '';

    addlyrics = ''
      set opus_path $argv[1]
      set filename (basename $opus_path .opus)
      set dir (dirname $opus_path)
      set lrc_path "$dir/$filename.lrc"

      set title (python3 -c "
from mutagen.oggopus import OggOpus
a = OggOpus('$opus_path')
v = a.get('title')
print(v[0] if v else '$filename')
")
      set artist (python3 -c "
from mutagen.oggopus import OggOpus
a = OggOpus('$opus_path')
v = a.get('artist')
print(v[0] if v else 'Unknown')
")
      set album (python3 -c "
from mutagen.oggopus import OggOpus
a = OggOpus('$opus_path')
v = a.get('album')
print(v[0] if v else 'Unknown')
")

      set clean_title (echo $title | sed 's/([^)]*)//g' | string trim)
      set query (string replace -a " " "+" "$clean_title $artist")
      echo "🎵 Searching lyrics for $clean_title - $artist..."
      set lyrics (curl -s "https://lrclib.net/api/search?q=$query" | jq -r '.[0].syncedLyrics // .[0].plainLyrics // empty')

      if test -n "$lyrics"
          printf "[ti:%s]\n[ar:%s]\n[al:%s]\n" $title $artist $album > $lrc_path
          string join \n $lyrics >> $lrc_path

          env OPUS="$opus_path" LRC="$lrc_path" python3 -c "
import os
from mutagen.oggopus import OggOpus
audio = OggOpus(os.environ['OPUS'])
content = open(os.environ['LRC']).read()
audio['LYRICS'] = [content]
audio['SYNCEDLYRICS'] = [content]
audio.save()
"
          echo "✓ Lyrics saved and embedded for $clean_title"
      else
          echo "✗ No lyrics found for $clean_title"
      end
    '';
  };
}
