#!/bin/sh
mute_status=$(pactl get-sink-mute @DEFAULT_SINK@)

if echo "$mute_status" | grep -q "yes"; then
    echo " Muted"
else
    percent=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
    echo " ${percent}%"
fi
