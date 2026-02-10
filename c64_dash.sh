#!/bin/bash
# CHECKS IF DISPLAY IS AVAILABLE
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0
fi

# LAUNCHES KIOSK IN CHROMIUM (DEFAULT ON PI)
# ALTERNATIVE: FIREFOX OR EPIPHANY
# START C64 SERVER IF NOT RUNNING
if ! pgrep -f "c64_server.py" > /dev/null; then
    echo "STARTING C64 BACKEND SERVER..."
    nohup python3 $HOME/c64-os/c64_server.py > /dev/null 2>&1 &
    sleep 2
fi

# LAUNCHES KIOSK IN CHROMIUM (DEFAULT ON PI)
# ALTERNATIVE: FIREFOX OR EPIPHANY
URL="http://localhost:8000/index.html"

if command -v chromium-browser &> /dev/null; then
    chromium-browser --kiosk --incognito "$URL" &
elif command -v firefox &> /dev/null; then
    firefox --kiosk "$URL" &
else
    echo "NO COMPATIBLE BROWSER FOUND FOR KIOSK MODE."
    xdg-open "$URL" &
fi