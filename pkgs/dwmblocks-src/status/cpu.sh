#!/bin/sh

printf " %.2f" "$(cut -d ' ' -f1 /proc/loadavg)"
