#!/bin/sh

# Get active connection, filtering out loopback (lo), docker, and bridges
# Then take only the top 1 result (head -n 1) to prevent double-text
active=$(nmcli -t -f TYPE,STATE,CONNECTION dev | grep ':connected' | grep -ivE 'loopback|^lo:|docker|vboxnet|br-' | head -n 1)

if [ -z "$active" ]; then
  printf "󰤭 Offline"
  exit 0
fi

type=$(echo "$active" | cut -d: -f1)
name=$(echo "$active" | cut -d: -f3)

case "$type" in
wifi)
  printf " %s" "$name"
  ;;
ethernet)
  printf "󰈀 Wired"
  ;;
*)
  printf "󰌘 %s" "$name"
  ;;
esac
