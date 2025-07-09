{ pkgs }:

pkgs.writeShellScriptBin "record-screen-area" ''
  if pidof wf-recorder > /dev/null; then
    pkill wf-recorder
  else
    FILE_NAME="$(date +%Y-%m-%d_%H-%m-%s).mp4"
    FILE_PATH="$HOME/Videos/$FILE_NAME"
    AUDIO_DEVICE="$(pactl get-default-sink).monitor"

    wf-recorder --audio="$AUDIO_DEVICE" -g "$(slurp)" -f "$FILE_PATH" &> /dev/null && mpv $FILE_NAME

    notify-send "Recording [$FILE_NAME] saved."
  fi
''
 
