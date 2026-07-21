#!/bin/sh
xrandr --output HDMI-2 --mode 1680x1050 --rate 59.95
xset r rate 200 35
picom --config ~/.config/picom/picom.conf -b
xwallpaper --zoom ~/walls/wallhaven-k81oe6.png
dwmblocks &
exec dwm
