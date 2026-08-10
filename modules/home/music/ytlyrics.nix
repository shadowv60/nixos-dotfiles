{ pkgs, ... }:
{
  programs.fish.functions = {
    ytlyrics = ''
      set opus_path $argv[1]

      if not test -f "$opus_path"
          echo "✗ File not found: $opus_path"
          return 1
      end

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

      set clean_title (echo $title | sed 's/([^)]*)//g' | string trim)

      echo "🎵 Searching YouTube Music for $clean_title - $artist..."

      env TITLE="$clean_title" ARTIST="$artist" OPUS="$opus_path" LRC="$lrc_path" python3 -c "
import os
from ytmusicapi import YTMusic

title = os.environ['TITLE']
artist = os.environ['ARTIST']
opus_path = os.environ['OPUS']
lrc_path = os.environ['LRC']

yt = YTMusic()

query = f'{title} {artist}'.strip()
results = yt.search(query, filter='songs')

if not results:
    print('NOTFOUND')
    raise SystemExit

video_id = results[0]['videoId']

watch_playlist = yt.get_watch_playlist(video_id)
lyrics_browse_id = watch_playlist.get('lyrics')

if not lyrics_browse_id:
    print('NOLYRICSID')
    raise SystemExit

lyrics_data = yt.get_lyrics(lyrics_browse_id, timestamps=True)

if not lyrics_data or not lyrics_data.get('lyrics'):
    print('NOLYRICS')
    raise SystemExit

synced = lyrics_data.get('hasTimestamps', False)
lines = lyrics_data['lyrics']

if synced and isinstance(lines, list):
    lrc_lines = []
    for line in lines:
        ms = line.start_time
        minutes = ms // 60000
        seconds = (ms % 60000) / 1000
        lrc_lines.append(f'[{minutes:02d}:{seconds:05.2f}] {line.text}')
    content = chr(10).join(lrc_lines)
else:
    content = lines if isinstance(lines, str) else chr(10).join(l.text for l in lines)

with open(lrc_path, 'w') as f:
    f.write(f'[ti:{title}]\n[ar:{artist}]\n')
    f.write(content)

from mutagen.oggopus import OggOpus
audio = OggOpus(opus_path)
audio['LYRICS'] = content
audio['SYNCEDLYRICS'] = content
audio.save()

print('SYNCED' if synced else 'PLAIN')
" | read -l lyric_status

      switch "$lyric_status"
          case SYNCED
              echo "✓ Synced lyrics from YouTube Music saved and embedded for $clean_title"
          case PLAIN
              echo "⚠ Only plain (unsynced) lyrics found on YouTube Music for $clean_title"
          case NOTFOUND
              echo "✗ No matching song found on YouTube Music for $clean_title"
          case NOLYRICSID
              echo "✗ No lyrics available on YouTube Music for $clean_title"
          case NOLYRICS
              echo "✗ Lyrics endpoint returned nothing for $clean_title"
          case '*'
              echo "✗ Unexpected error fetching lyrics for $clean_title"
      end
    '';
  };
}
