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

adb shell am start \
  -n com.android.camera/com.android.camera.VideoCamera \
  --ei android.intent.extras.CAMERA_FACING 0 \
  -a android.media.action.VIDEO_CAPTURE


# sudo modprobe -r v4l2loopback

# sudo modprobe v4l2loopback exclusive_caps=1 video_nr=5 card_label="Phone Camera"


scrcpy --lock-video-orientation=0 --v4l2-sink=/dev/video6 -N \
  --stay-awake \
 --crop 1490:900:0:900
