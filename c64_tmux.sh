#!/bin/bash
# c64_tmux.sh - Launches c64-os with Border
# Based on nickbild/pi-64

SESSION="c64"
BORDER_SCRIPT="$HOME/c64-os/display_border.sh"

# Ensure border script exists locally if not found
if [ ! -f "$BORDER_SCRIPT" ]; then
    # Fallback if installed in root or current dir
    if [ -f "./display_border.sh" ]; then
        BORDER_SCRIPT="./display_border.sh"
    else
        echo "Error: display_border.sh not found."
        exit 1
    fi
fi

# Kill existing session if any (clean start)
tmux kill-session -t $SESSION 2>/dev/null

# Create new session (detached)
# Assumes 1080p-ish text mode, adjusting for standard terminal size
tmux new-session -d -s $SESSION -x 240 -y 67

# --- LAYOUT CREATION (7 Panes) ---
# 0: Top Border
# 1: Left | 2: Main | 3: Right
# 4: Bot Left | 5: Bot Mid | 6: Bot Right

tmux split-window -v -t $SESSION:0
tmux split-window -h -t $SESSION:0.1
tmux split-window -h -t $SESSION:0.2

tmux select-pane -t $SESSION:0.0
tmux split-window -v -t $SESSION:0.0

tmux select-pane -t $SESSION:0.2
tmux split-window -h -t $SESSION:0.2

# Resize - Tweaked for standard HD/Kiosk
# Top Border
tmux resize-pane -t $SESSION:0.0 -y 2

# Main Middle Row Height
tmux resize-pane -t $SESSION:0.1 -y 50
tmux resize-pane -t $SESSION:0.2 -y 50
tmux resize-pane -t $SESSION:0.3 -y 50

# Side Widths
tmux resize-pane -t $SESSION:0.1 -x 4
tmux resize-pane -t $SESSION:0.3 -x 4

# Load border script into non-main panes
for pane in 0 1 3 4 5 6; do
    tmux send-keys -t $SESSION:0.$pane "source $BORDER_SCRIPT" Enter
done

# Select Main Pane (2) and clear
tmux select-pane -t $SESSION:0.2
tmux send-keys -t $SESSION:0.2 "clear" Enter
tmux send-keys -t $SESSION:0.2 "echo '**** c64-os READY ****'" Enter

# Attach
tmux attach-session -t $SESSION
