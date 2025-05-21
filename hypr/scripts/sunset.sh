#!/bin/sh

# Get the current hour (in 24-hour format)
current_hour=$(date +%H)

# If it’s after 20:00 or before 7:00, hyprsunset -t 4000, else identity.
if [ "$current_hour" -ge 20 ] || [ "$current_hour" -le 6 ]; then
  echo “Changing to nighttime hyprsunset”
  hyprctl hyprsunset temperature 4000
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
  echo “Changing to default hyprsunset”
  hyprctl hyprsunset identity
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' && gsettings set org.gnome.desktop.interface color-scheme 'default'
fi
