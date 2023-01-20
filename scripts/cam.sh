sudo modprobe -r v4l2loopback

sudo modprobe v4l2loopback exclusive_caps=1

SCREEN_STATE=$(adb shell dumpsys nfc | grep -E 'mScreenState=' | sed 's/mScreenState=//g')

[[ "$SCREEN_STATE" = "OFF_LOCKED" ]] && adb shell input keyevent 26

adb shell am start \
  -n com.android.camera/com.android.camera.VideoCamera \
  --ei android.intent.extras.CAMERA_FACING 1 \
  -a android.media.action.VIDEO_CAPTURE

scrcpy --lock-video-orientation=0 --v4l2-sink=/dev/video2 -N \
  --stay-awake \
#  --power-off-on-close \
#  --crop 1080:1490:0:290

