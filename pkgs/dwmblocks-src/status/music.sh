#!/bin/sh

MAX=15

# 1. Dynamically find the player name for Zen
# This looks for any player starting with 'zen' or 'firefox'
ZEN_PLAYER=$(playerctl -l 2>/dev/null | grep -E 'zen|firefox' | head -n 1)
CHROME_PLAYER=$(playerctl -l 2>/dev/null | grep 'chromium' | head -n 1)

# 2. Get statuses using the dynamic names
ZEN_STATUS=$(playerctl -p "$ZEN_PLAYER" status 2>/dev/null)
CHROME_STATUS=$(playerctl -p "$CHROME_PLAYER" status 2>/dev/null)
MPD_STATUS=$(playerctl -p mpd status 2>/dev/null)

# 3. Priority Logic: Zen > Chromium > MPD
if [ "$ZEN_STATUS" = "Playing" ]; then
  PLAYER="$ZEN_PLAYER"
  status="$ZEN_STATUS"
elif [ "$CHROME_STATUS" = "Playing" ]; then
  PLAYER="$CHROME_PLAYER"
  status="$CHROME_STATUS"
elif [ -n "$MPD_STATUS" ]; then
  PLAYER="mpd"
  status="$MPD_STATUS"
else
  # Fallback to the first player found by playerctl
  PLAYER=$(playerctl -l 2>/dev/null | head -n 1)
  status=$(playerctl -p "$PLAYER" status 2>/dev/null)
fi

# Exit if no player or status found
if [ -z "$status" ]; then
  printf " No music"
  exit 0
fi

# 4. Metadata Gathering
icon=""
[ "$status" = "Playing" ] && icon=""

artist=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null)
title=$(playerctl -p "$PLAYER" metadata title 2>/dev/null)

# Clean up text
if [ -n "$artist" ] && [ -n "$title" ]; then
  text="$title - $artist"
elif [ -n "$title" ]; then
  text="$title"
else
  text="Unknown"
fi

# Truncate if too long
if [ ${#text} -gt $MAX ]; then
  text=$(printf "%s" "$text" | cut -c 1-$((MAX - 1)))"…"
fi

printf "%s %s" "$icon" "$text"

# 5. Handle clicks
case "$BLOCK_BUTTON" in
  1) playerctl -p "$PLAYER" play-pause ;;
  2) playerctl -p "$PLAYER" previous ;;
  3) playerctl -p "$PLAYER" next ;;
esac
