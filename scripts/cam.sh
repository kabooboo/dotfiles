function unlock() {
  adb shell input keyevent 26
}

PHONE_IP="$(arp -a | grep $PHONE_MAC | sed -nr 's/.*\((.+)\).*/\1/p')"

echo "Found phone IP: ${PHONE_IP}"

adb connect $PHONE_IP:5555

SCREEN_STATE=$(adb shell dumpsys nfc | grep -E 'mScreenState=' | sed 's/mScreenState=//g')

[ "$SCREEN_STATE" = "OFF_LOCKED" ] && unlock

adb shell am start -n com.dev47apps.droidcamx/.DroidCamX

sleep 2

droidcam-cli adb 4747

adb shell input keyevent 26
