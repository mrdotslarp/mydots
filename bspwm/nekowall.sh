#!/bin/bash

# Configuration
VIDEO_DIR="$HOME/Videos/livewall"
RESOLUTION="1920x1080"

clear
echo "#########################"
echo "####   WALL ENGINE   ####"
echo "#########################"
echo ""

# List available wallpapers numerically
echo "Available Wallpapers in $VIDEO_DIR:"
ls "$VIDEO_DIR" | grep -E '^[0-9]+\.mp4$' | sed 's/\.mp4//' | sort -n | fmt -w 60
echo ""

echo "Enter a number to set wallpaper"
echo "Enter 'k' to Kill/Stop wallpaper"
read -p "Selection: " USER_INPUT

# Handle Kill Command
if [[ "$USER_INPUT" == "k" ]]; then
    echo "Stopping wallpaper..."
    pkill xwinwrap
    sleep 1
    exit 0
fi

FILE_PATH="$VIDEO_DIR/$USER_INPUT.mp4"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: Wallpaper '$USER_INPUT.mp4' not found!"
    sleep 2
    exit 1
fi

# Check if xwinwrap is already running
if pgrep -x "xwinwrap" > /dev/null; then
    echo "Existing wallpaper detected. Restarting Engine..."
    pkill xwinwrap
    # Small delay to ensure the window is released by the X server
    sleep 0.5
else
    echo "Starting Engine for the first time..."
fi

echo "Applying wallpaper $USER_INPUT..."

# Kill existing processes to prevent stacking
pkill xwinwrap

# Your Optimized Command
nice -n 19 xwinwrap -ov -ni -g "$RESOLUTION" -- \
    mpv --wid=%WID --loop --no-audio --hwdec=vaapi --vo=gpu \
    --gpu-api=opengl --profile=fast --vd-lavc-fast \
    --vd-lavc-threads=1 --cache=no --demuxer-readahead-secs=0 \
    --demuxer-max-bytes=1M --vd-lavc-dr=yes --dither=no \
    --correct-downscaling=no --scale=bilinear --hdr-compute-peak=no \
    --video-sync=display-resample --framedrop=vo --terminal=no \
    --ytdl=no --msg-level=all=no \
    "$FILE_PATH" > /dev/null 2>&1 &

echo "Done!"
sleep 1
