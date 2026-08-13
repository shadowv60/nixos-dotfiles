{ pkgs, ... }:
{
  programs.fish.functions = {
    _convertflac_one = ''
      set input $argv[1]
      set bitrate $argv[2]
      set opus (string replace -r '\.[^.]+$' '.opus' -- $input)
      set cover (mktemp --suffix=.jpg)

      ffmpeg -y -i "$input" -an -vcodec copy "$cover" -v quiet 2>/dev/null

      # If the extracted cover art is over 1MB, recompress it down.
      # Cap dimensions at 1200x1200 and step through JPEG quality
      # levels until it's under the threshold.
      if test -s "$cover"
          set cover_size (stat -c %s "$cover")
          if test "$cover_size" -gt 1048576
              set cover_resized (mktemp --suffix=.jpg)
              for q in 5 8 12 16 20
                  ffmpeg -y -i "$cover" \
                      -vf "scale='min(1200,iw)':'min(1200,ih)':force_original_aspect_ratio=decrease" \
                      -q:v $q "$cover_resized" -v quiet 2>/dev/null
                  set new_size (stat -c %s "$cover_resized")
                  if test "$new_size" -le 1048576
                      break
                  end
              end
              echo "🖼  Cover compressed: "(math "$cover_size / 1024")"KB -> "(math "$new_size / 1024")"KB"
              mv "$cover_resized" "$cover"
          end
      end

      if not ffmpeg -y -i "$input" \
          -map 0:a -map_metadata 0 \
          -c:a libopus -b:a "$bitrate"k -vbr on \
          -af "aresample=resampler=soxr:osr=48000:dither_method=triangular" \
          -v quiet "$opus"
          echo "Error: $input"
          rm -f "$cover"
          return 1
      end

      touch -r "$input" "$opus"

      if test -s "$cover"
          env OPUS="$opus" JPG="$cover" python3 -c "
import os
from mutagen.oggopus import OggOpus
from mutagen.flac import Picture
import base64
audio = OggOpus(os.environ['OPUS'])
pic = Picture()
pic.type = 3
pic.mime = 'image/jpeg'
pic.desc = 'Cover'
with open(os.environ['JPG'], 'rb') as f:
    pic.data = f.read()
audio['METADATA_BLOCK_PICTURE'] = [base64.b64encode(pic.write()).decode('ascii')]
audio.save()
"
      end

      rm -f "$cover"

      env OPUS="$opus" flock /tmp/musicbrainz.lock python3 -c "
import os, time
from mutagen.oggopus import OggOpus
import musicbrainzngs as mb

mb.set_useragent('wolk-convertflac', '1.0', 'shadowvpsl48@gmail.com')

audio = OggOpus(os.environ['OPUS'])

title = audio.get('title', [\"\"])[0]
if not title:
    print('SKIP_NO_TITLE')
    raise SystemExit

current_artists = [a.strip() for a in audio.get('artist', []) if a.strip()]

try:
    hint = current_artists[0] if current_artists else \"\"
    query = title if not hint else f'{title} AND artist:{hint}'
    result = mb.search_recordings(query=query, limit=1)
    time.sleep(1.1)

    recordings = result.get('recording-list', [])
    if not recordings:
        print('NO_MATCH')
        raise SystemExit

    rec = recordings[0]
    credit = rec.get('artist-credit', [])
    mb_artists = [c['artist']['name'] for c in credit if isinstance(c, dict) and 'artist' in c]

    applied = []

    if len(mb_artists) > len(current_artists):
        audio['artist'] = mb_artists
        applied.append(f'artist ({len(current_artists)}->{len(mb_artists)})')

    if not audio.get('album', [\"\"])[0]:
        releases = rec.get('release-list', [])
        if releases:
            audio['album'] = releases[0]['title']
            applied.append('album')

    if not audio.get('date', [\"\"])[0]:
        releases = rec.get('release-list', [])
        dates = [r.get('date') for r in releases if r.get('date')]
        if dates:
            audio['date'] = sorted(dates)[0]
            applied.append('date')

    if applied:
        audio.save()
        print('APPLIED:' + ','.join(applied))
    else:
        print('NOTHING_NEW')

except Exception as e:
    print('ERROR:' + str(e))
"

      set lyrics_status (env INPUT="$input" OPUS="$opus" python3 -c "
import os, re
import mutagen
from mutagen.oggopus import OggOpus
src = mutagen.File(os.environ['INPUT'])
dst = OggOpus(os.environ['OPUS'])
def get(tags, keys):
    if tags is None:
        return None
    for k in keys:
        try:
            if k in tags:
                v = tags[k]
                return v[0] if isinstance(v, list) else str(v)
        except (KeyError, ValueError):
            continue
    return None
synced = get(src, ('syncedlyrics', 'SYNCEDLYRICS', '\xa9lyr', 'LYRICS-XXX', 'USLT'))
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
          if not addlyrics "$opus"
              echo "↪ Falling back to YouTube Music for $opus"
              ytlyrics "$opus"
          end
      end
    '';

    convertflac = ''
      set bitrate 160
      if test (count $argv) -gt 0
          set bitrate $argv[1]
      end

      for f in *.flac *.wav *.m4a *.mp3 *.dsf
          test -f "$f"; or continue
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
      echo "🎵 Searching synced lyrics for $clean_title - $artist..."
      set lyrics (curl -s "https://lrclib.net/api/search?q=$query" | jq -r '.[0].syncedLyrics // empty')

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
          echo "✓ Synced lyrics saved and embedded for $clean_title"
          return 0
      else
          echo "✗ No synced lyrics found on lrclib for $clean_title"
          return 1
      end
    '';
  };
}
