#!/bin/sh

# Get volume info from pipewire
vol_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

# Check for mute status first
if echo "$vol_info" | grep -q "MUTED"; then
    echo " Muted"
else
    # Extract the decimal, multiply by 100, and round to nearest whole number
    percent=$(echo "$vol_info" | awk '{print int($2 * 100 + 0.5)}')
    echo " ${percent}%"
fi
