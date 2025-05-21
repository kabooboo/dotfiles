#!/bin/sh

# Get the current hour (in 24-hour format)
current_hour=$(date +%H)

# If it’s after 20:00 or before 7:00, hyprsunset -t 4400, else identity.
if [ "$current_hour" -ge 20 ] || [ "$current_hour" -le 6 ]; then
  echo “Changing to nighttime hyprsunset”
  hyprctl hyprsunset temperature 4400
else
  echo “Changing to default hyprsunset”
  hyprctl hyprsunset identity
fi