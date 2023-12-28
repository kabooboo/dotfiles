#!/bin/bash

if [ "$(cat /proc/acpi/button/lid/LID0/state | awk '{print $2}')" == "open" ]; then
  EDP1_STRING="--auto --pos 0x1080 --rotate normal"
else
  EDP1_STRING="--off"
fi

if [ "$(xrandr  | grep -E '^HDMI-1' | grep ' connected ' | wc -l)" == "1" ]; then
  HDMI1_STRING="--auto --pos 0x0 --rotate normal"
else
  HDMI1_STRING="--off"
fi

if [ "$(xrandr  | grep -E '^HDMI-2' | grep ' connected ' | wc -l)" == "1" ]; then
  HDMI2_STRING="--auto --pos 0x0 --rotate normal"
else
  HDMI2_STRING="--off"
fi

if [ "$(xrandr  | grep -E '^HDMI-3' | grep ' connected ' | wc -l)" == "1" ]; then
  HDMI3_STRING="--auto --pos 0x0 --rotate normal"
else
  HDMI3_STRING="--off"
fi

if [ "$(xrandr  | grep -E '^DP-1' | grep ' connected ' | wc -l)" == "1" ]; then
  DP1_STRING="--auto --pos 0x0 --rotate normal"
else
  DP1_STRING="--off"
fi

if [ "$(xrandr  | grep -E '^DP-2' | grep ' connected ' | wc -l)" == "1" ]; then
  DP2_STRING="--auto --pos 0x0 --rotate normal"
else
  DP2_STRING="--off"
fi

eval "xrandr \
  --output eDP-1 $EDP1_STRING \
  --output HDMI-1 $HDMI1_STRING \
  --output HDMI-2 $HDMI2_STRING \
  --output HDMI-3 $HDMI3_STRING \
  --output DP-1 $DP1_STRING \
  --output DP-2 $DP2_STRING"
