{ pkgs, ... }:
let
  convertflacOne = pkgs.writeShellScriptBin "_convertflac_one" ''
    set -uo pipefail

    INPUT="$1"
    BITRATE="$2"
    OPUS="''${INPUT%.*}.opus"
    COVER="$(mktemp --suffix=.jpg)"

    ffmpeg -y -i "$INPUT" -an -vcodec copy "$COVER" -v quiet 2>/dev/null

    if [ -s "$COVER" ]; then
      COVER_SIZE="$(stat -c%s "$COVER")"
      if [ "$COVER_SIZE" -gt 1048576 ]; then
        COVER_RESIZED="$(mktemp --suffix=.jpg)"
        NEW_SIZE="$COVER_SIZE"
        for Q in 5 8 12 16 20; do
          ffmpeg -y -i "$COVER" \
              -vf "scale='min(1200,iw)':'min(1200,ih)':force_original_aspect_ratio=decrease" \
              -q:v "$Q" "$COVER_RESIZED" -v quiet 2>/dev/null
          NEW_SIZE="$(stat -c%s "$COVER_RESIZED")"
          if [ "$NEW_SIZE" -le 1048576 ]; then
            break
          fi
        done
        echo "🖼  Cover compressed: $((COVER_SIZE / 1024))KB -> $((NEW_SIZE / 1024))KB"
        mv "$COVER_RESIZED" "$COVER"
      fi
    fi

    if ! ffmpeg -y -i "$INPUT" \
        -map 0:a -map_metadata 0 \
        -c:a libopus -b:a "''${BITRATE}k" -vbr on \
        -af "aresample=resampler=soxr:osr=48000:dither_method=triangular" \
        -v quiet "$OPUS"; then
      echo "Error: $INPUT"
      rm -f "$COVER"
      exit 1
    fi

    touch -r "$INPUT" "$OPUS"

    if [ -s "$COVER" ]; then
      OPUS="$OPUS" JPG="$COVER" python3 <<'PYEOF'
    import os
    from mutagen.oggopus import OggOpus
    from mutagen.flac import Picture
    import base64
    audio = OggOpus(os.environ["OPUS"])
    pic = Picture()
    pic.type = 3
    pic.mime = "image/jpeg"
    pic.desc = "Cover"
    with open(os.environ["JPG"], "rb") as f:
        pic.data = f.read()
    audio["METADATA_BLOCK_PICTURE"] = [base64.b64encode(pic.write()).decode("ascii")]
    audio.save()
    PYEOF
    fi

    rm -f "$COVER"

    # MusicBrainz enrichment: fills missing album/date, and only replaces
    # 'artist' when MB returns MORE credited artists than currently tagged
    # (never downgrades a manual fix). Serialized via flock since MB
    # rate-limits to 1 req/sec per IP. 10s timeout so a slow MB server
    # can't hang the batch.
    OPUS="$OPUS" flock /tmp/musicbrainz.lock python3 <<'PYEOF'
    import os, time, socket
    socket.setdefaulttimeout(10)
    from mutagen.oggopus import OggOpus
    import musicbrainzngs as mb

    mb.set_useragent("wolk-convertflac", "1.0", "shadowvpsl48@gmail.com")

    audio = OggOpus(os.environ["OPUS"])

    title = audio.get("title", [""])[0]
    if not title:
        print("SKIP_NO_TITLE")
        raise SystemExit

    current_artists = [a.strip() for a in audio.get("artist", []) if a.strip()]

    try:
        hint = current_artists[0] if current_artists else ""
        query = title if not hint else f"{title} AND artist:{hint}"
        result = mb.search_recordings(query=query, limit=1)
        time.sleep(1.1)

        recordings = result.get("recording-list", [])
        if not recordings:
            print("NO_MATCH")
            raise SystemExit

        rec = recordings[0]
        credit = rec.get("artist-credit", [])
        mb_artists = [c["artist"]["name"] for c in credit if isinstance(c, dict) and "artist" in c]

        applied = []

        if len(mb_artists) > len(current_artists):
            audio["artist"] = mb_artists
            applied.append(f"artist ({len(current_artists)}->{len(mb_artists)})")

        if not audio.get("album", [""])[0]:
            releases = rec.get("release-list", [])
            if releases:
                audio["album"] = releases[0]["title"]
                applied.append("album")

        if not audio.get("date", [""])[0]:
            releases = rec.get("release-list", [])
            dates = [r.get("date") for r in releases if r.get("date")]
            if dates:
                audio["date"] = sorted(dates)[0]
                applied.append("date")

        if applied:
            audio.save()
            print("APPLIED:" + ",".join(applied))
        else:
            print("NOTHING_NEW")

    except Exception as e:
        print("ERROR:" + str(e))
    PYEOF

    LYRICS_STATUS="$(INPUT="$INPUT" OPUS="$OPUS" python3 <<'PYEOF'
    import os, re
    import mutagen
    from mutagen.oggopus import OggOpus
    src = mutagen.File(os.environ["INPUT"])
    dst = OggOpus(os.environ["OPUS"])
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
    synced = get(src, ("syncedlyrics", "SYNCEDLYRICS", "\xa9lyr", "LYRICS-XXX", "USLT"))
    plain = get(src, ("lyrics", "LYRICS"))
    has_timestamps = bool(synced and re.search(r"\[\d{2}:\d{2}", synced))
    if has_timestamps:
        dst["LYRICS"] = synced
        dst["SYNCEDLYRICS"] = synced
        print("HAS_SYNCED")
    else:
        if plain:
            dst["LYRICS"] = plain
        print("NO_SYNCED")
    dst.save()
    PYEOF
    )"

    echo "🎵 $OPUS: $LYRICS_STATUS"

    if [ "$LYRICS_STATUS" = "NO_SYNCED" ]; then
      if ! fish -c 'addlyrics $argv[1]' -- "$OPUS"; then
        echo "↪ Falling back to YouTube Music for $OPUS"
        fish -c 'ytlyrics $argv[1]' -- "$OPUS"
      fi
    fi
  '';

  convertflac = pkgs.writeShellScriptBin "convertflac" ''
    set -uo pipefail
    BITRATE="''${1:-160}"

    shopt -s nullglob
    files=(*.flac *.wav *.m4a *.mp3 *.dsf)

    if [ ''${#files[@]} -eq 0 ]; then
      echo "No audio files found."
      exit 0
    fi

    printf '%s\0' "''${files[@]}" | parallel -0 -j "$(nproc)" --progress _convertflac_one {} "$BITRATE"
  '';
in
{
  home.packages = [ convertflacOne convertflac ];

  programs.fish.functions = {
      addlyrics = ''
      set opus_path $argv[1]
      set filename (basename $opus_path .opus)
      set dir (dirname $opus_path)
      set lrc_path "$dir/$filename.lrc"

      set title (env OPUS="$opus_path" FALLBACK="$filename" python3 -c "
import os
from mutagen.oggopus import OggOpus
a = OggOpus(os.environ['OPUS'])
v = a.get('title')
print(v[0] if v else os.environ['FALLBACK'])
")
      set artist (env OPUS="$opus_path" python3 -c "
import os
from mutagen.oggopus import OggOpus
a = OggOpus(os.environ['OPUS'])
v = a.get('artist')
print(v[0] if v else 'Unknown')
")
      set album (env OPUS="$opus_path" python3 -c "
import os
from mutagen.oggopus import OggOpus
a = OggOpus(os.environ['OPUS'])
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
