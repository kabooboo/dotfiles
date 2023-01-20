#!/bin/bash

source ~/.secrets/credentials.sh

function unlock() {
  adb shell input keyevent 26
}
LOCAL_NET_CIDR="$(ip route | grep src | grep wlp0s20f3 | awk '{print $1}')"

# Scan network to find phone
nmap -sn $LOCAL_NET_CIDR

echo $PHONE_MAC

PHONE_IP="$(arp -a | grep $PHONE_MAC | sed -nr 's/.*\((.+)\).*/\1/p')"

echo "Found phone IP: ${PHONE_IP}"

adb connect $PHONE_IP:5555

SCREEN_STATE=$(adb shell dumpsys nfc | grep -E 'mScreenState=' | sed 's/mScreenState=//g')

[ "$SCREEN_STATE" = "OFF_LOCKED" ] && unlock

adb shell am start -n com.dev47apps.droidcamx/.DroidCamX

sleep 2

# Start droidcam infinitely until it starts properly
while true; do
  droidcam-cli -nocontrols adb 4747 2>&1 | while read LOGLINE
  do
    [[ "${LOGLINE}" == *"Error: Connection reset!"* ]] && pkill -P $$ droidcam-cli
  done
  sleep 2
  echo "Droidcam failed (Error: Connection reset!). Restarting!"
done
