#!/bin/sh

used=$(free -m | awk '/^Mem:/ {print $3}')
total=$(free -m | awk '/^Mem:/ {print $2}')

percent=$(( used * 100 / total ))

echo " ${percent}%"
