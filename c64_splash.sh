#!/bin/bash
# c64-os SPLASH SCREEN LOADER
# USES FBI TO RENDER DIRECTLY TO FRAMEBUFFER

SPLASH_IMG="$(dirname "$0")/Pictures/commodoreblank.png"

if [ -f "$SPLASH_IMG" ]; then
    # -d: device (fb0 is usually HDMI/Screen)
    # -T 1: terminal 1
    # --noverbose: silence output
    # -a: autozoom
    sudo fbi -d /dev/fb0 -T 1 --noverbose -a "$SPLASH_IMG" > /dev/null 2>&1
else
    echo "SPLASH IMAGE NOT FOUND."
fi