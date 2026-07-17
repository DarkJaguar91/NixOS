#!/bin/sh
# Toggle a region recording: first press selects an area with slurp and starts
# gpu-screen-recorder; second press stops it (SIGINT finalizes the file).
# Kept separate from the noctalia screen_recorder plugin, which only does
# focused-monitor/portal capture; its bar widget still picks up this process.

if pkill -INT -f 'gpu-screen-recorder -w region'; then
    exit 0
fi

region=$(slurp -f '%wx%h+%x+%y') || exit 0

dir="$HOME/Videos/Recordings"
mkdir -p "$dir"
exec gpu-screen-recorder -w region -region "$region" -f 60 -a default_output \
    -o "$dir/recording_$(date +%Y%m%d_%H%M%S).mp4"
