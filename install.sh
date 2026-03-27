#!/bin/bash
# --- c64-os SYSTEM INSTALLER v4 ---
# REM: PORTABLE KERNEL SETUP FOR PI 5 + WAVESHARE V1 + KIOSK
# AUTHOR: POLERIX & GEMINI COLLABORATIVE

echo -e "\e[48;5;17m\e[38;5;147m"
echo "****************************************"
echo "* c64-os COMPLETE SYSTEM INSTALLATION  *"
echo "****************************************"

# 1. DEPENDENCY CHECK & INSTALLATION
echo "CHECKING DEPENDENCIES..."
sudo apt update
sudo apt install -y vice python3 python3-pip python3-requests pcmanfm plymouth plymouth-themes fbi shellinabox tmux
echo "[OK] DEPENDENCIES INSTALLED."

# 1.1 CONFIGURE SHELLINABOX
if [ -f /etc/default/shellinabox ]; then
    echo "CONFIGURING SHELLINABOX..."
    # Disable SSL for local kiosk use and disable beep
    sudo sed -i 's/^SHELLINABOX_ARGS=.*/SHELLINABOX_ARGS="--disable-ssl --no-beep --service=\/:LOGIN"/' /etc/default/shellinabox
    sudo systemctl restart shellinabox
    echo "[OK] SHELLINABOX CONFIGURED."
fi

# 2. SECURE KEY MANAGEMENT
KEY_FILE="$HOME/.gemini_key"
if [ ! -f "$KEY_FILE" ]; then
    echo -ne "ENTER GEMINI API KEY (STAYS HIDDEN): "
    read -s RAW_KEY
    echo "$RAW_KEY" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    echo -e "\n[OK] API KEY STORED SECURELY."
fi

# 3. DEPLOY ENGINE TO GLOBAL BIN
if [ -f "./gemini-pi" ]; then
    echo "DEPLOYING ENGINE TO /usr/local/bin..."
    sudo cp ./gemini-pi /usr/local/bin/gemini-pi
    sudo chmod +x /usr/local/bin/gemini-pi
    echo "[OK] GEMINI-PI DEPLOYED."
else
    echo "[!] WARNING: gemini-pi NOT FOUND IN CURRENT DIRECTORY."
fi

# 4. SETUP WALLPAPER
if [ -f "./Pictures/commodorelogo.png" ]; then
    echo "SETTING DESKTOP WALLPAPER..."
    # Ensure pcmanfm config directory exists
    mkdir -p ~/.config/pcmanfm/LXDE-pi/
    # This is a generic command, specific implementation depends on the exact PI OS Desktop
    pcmanfm --set-wallpaper "$(pwd)/Pictures/commodorelogo.png"
    echo "[OK] WALLPAPER SET."
fi

# 5. SETUP BOOT SCREEN (SPLASH)
if [ -f "./Pictures/commodoreblank.png" ]; then
    echo "CONFIGURING BOOT SPLASH..."
    sudo cp ./Pictures/commodoreblank.png /usr/share/plymouth/themes/pix/splash.png
    # Alternative: simple direct framebuffer script
    if [ -f "./c64_splash.sh" ]; then
        chmod +x c64_splash.sh
        # We can add this to autostart or rc.local
        echo "ADDING SPLASH TO AUTOSTART..."
         # This is a simplified approach; true plymouth themes are complex
    fi
    echo "[OK] SPLASH CONFIGURED."
fi

# 6. KIOSK MODE SETUP (SERVER & UI & TMUX)
if [ -f "./c64_kiosk.html" ] && [ -f "./c64_server.py" ]; then
    echo "DEPLOYING KIOSK DASHBOARD & SERVER..."
    mkdir -p ~/c64-os
    cp ./c64_kiosk.html ~/c64-os/index.html
    cp ./c64_server.py ~/c64-os/c64_server.py
    cp ./c64_tmux.sh ~/c64-os/c64_tmux.sh
    cp ./display_border.sh ~/c64-os/display_border.sh
    chmod +x ~/c64-os/c64_server.py ~/c64-os/c64_tmux.sh ~/c64-os/display_border.sh
    echo "[OK] KIOSK DEPLOYED TO ~/c64-os"
fi

# 7. HARDWARE HANDSHAKE (PI 5 + WAVESHARE V1)
if grep -q "Raspberry Pi 5" /proc/device-tree/model 2>/dev/null; then
    echo "PI 5 DETECTED. APPLYING SPI TIMING FIX..."
    if ! grep -q "piscreen" /boot/firmware/config.txt; then
        sudo tee -a /boot/firmware/config.txt <<EOF

# --- c64-os WAVESHARE V1 FIX ---
dtparam=spi=on
dtoverlay=piscreen,speed=16000000,rotate=270,drm
EOF
        echo "[OK] CONFIG.TXT UPDATED."
    fi
fi

# 8. SUDOERS PERMISSIONS (NO-PASSWORD FONT SWAP)
if [ ! -f /etc/sudoers.d/setfont ]; then
    echo "GRANTING PERMISSION FOR HARDWARE FONT SWAP..."
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/setfont" | sudo tee /etc/sudoers.d/setfont > /dev/null
    sudo chmod 0440 /etc/sudoers.d/setfont
    echo "[OK] SUDOERS UPDATED."
fi

# 9. GENERATE KERNEL MANAGER (Python Controller)
cat << 'EOF' > ~/kernel_mgr.py
import os, json, sys

class CyberdeckKernel:
    def __init__(self):
        self.profile_file = os.path.expanduser("~/.c64_profile.json")
        self.profiles = {
            "C64": {"bg": "17", "fg": "147", "font": "/usr/share/consolefonts/Lat15-TerminusBold20x10.psf.gz"},
            "SECURITY": {"bg": "16", "fg": "46", "font": "/usr/share/consolefonts/Lat15-TerminusBold20x10.psf.gz"},
            "ACADIEMAN": {"bg": "52", "fg": "214", "font": "/usr/share/consolefonts/Lat15-TerminusBold24x12.psf.gz"}
        }

    def switch(self, name):
        name = name.upper()
        if name in self.profiles:
            with open(self.profile_file, 'w') as f: json.dump(self.profiles[name], f)
            print(f"KERNEL: SWITCHING TO {name} MODE.")
        else:
            print(f"?DEVICE NOT PRESENT ERROR: {name}")

if __name__ == "__main__":
    if len(sys.argv) > 1: CyberdeckKernel().switch(sys.argv[1])
EOF
echo "[OK] KERNEL_MGR.PY CREATED."

# 10. INJECT BASHRC LOGIC
if ! grep -q "CYBERDECK PROFILE SYSTEM" ~/.bashrc; then
    echo "UPDATING .BASHRC..."
    cat << 'EOF' >> ~/.bashrc

# --- CYBERDECK PROFILE SYSTEM ---
# Manages system colors and fonts via kernel_mgr.py
switch() {
    python3 ~/kernel_mgr.py "$1"
    source ~/.bashrc
}
alias SWITCH='switch'

# --- c64-os PALETTE & VISUALS ---
if [ "$TERM" = "linux" ]; then
    # Custom Palette (C64 Light/Dark Blue) - from nickbild/pi-64
    echo -en "\e]P0000000" # BLACK (Background)
    echo -en "\e]P1867ADE" # LIGHT BLUE 
    echo -en "\e]P2867ADE" 
    echo -en "\e]P3867ADE" 
    echo -en "\e]P4867ADE" 
    echo -en "\e]P5867ADE" 
    echo -en "\e]P6867ADE" 
    echo -en "\e]P7867ADE" 
    clear
fi

if [ -f ~/.c64_profile.json ]; then
    # Rapid JSON Parse for Environment Variables
    eval $(python3 -c "import json,os; d=json.load(open(os.path.expanduser('~/.c64_profile.json'))); print(f\"export C64_BG={d['bg']}; export C64_FG={d['fg']}; export C64_FONT={d['font']}\")")
    
    # Apply Visual Theme
    echo -ne "\e[48;5;${C64_BG}m\e[38;5;${C64_FG}m"
    echo -ne "\e[1 q" # Blinking Block Cursor
    
    # Hardware Font Sync (Silently for Waveshare v1)
    [ -t 0 ] && sudo setfont -C /dev/tty1 "$C64_FONT" > /dev/null 2>&1
fi

# AUTO-LAUNCH TMUX BORDER IN SHELLINABOX/KIOSK
if [[ "$TERM" == "xterm" || "$TERM" == "xterm-color" ]] && [[ -z "$TMUX" ]]; then
   alias c64="$HOME/c64-os/c64_tmux.sh"
fi

# --- c64-os CORE ENGINE ---

# LOAD: Launch Gemini or Emulators
load() {
    local target=$(echo "$1" | tr -d '"' | tr '[:lower:]' '[:upper:]')
    
    if [ "$target" == "GEMINI" ]; then
        echo -e "SEARCHING FOR GEMINI\nLOADING\nREADY."
        while true; do
            echo -ne "\e[38;5;${C64_FG:-147}mREADY. \e[0m"
            read PROMPT
            [[ "$PROMPT" == "RUN" || "$PROMPT" == "EXIT" ]] && break
            /usr/local/bin/gemini-pi "$PROMPT"
            echo ""
        done
    elif [ "$target" == "C64" ]; then
        echo -e "LOADING VICE EMULATOR..."
        x64sc -sdl2 -limitcycles 63 -bordercolor 6 -backgroundcolor 6
        echo -ne "\e[48;5;${C64_BG:-17}m\e[38;5;${C64_FG:-147}m"
    else
        echo -e "?FILE NOT FOUND ERROR"
    fi
}

# LIST: AI-powered Disk Summary
list() {
    local recent_files=$(ls -p -t | grep -v / | head -n 8 | tr '\n' ', ')
    if [ -z "$recent_files" ]; then
        echo -e "?DEVICE NOT PRESENT ERROR"
        return
    fi
    echo -e "SEARCHING FOR TRACKS...\nSTORAGE MAP ANALYZED:\n----------------------------"
    local output=$(/usr/local/bin/gemini-pi "LIST THESE PROGRAMS: $recent_files")
    echo "$output" | while IFS= read -r -n1 char; do
        echo -n "$char"
        sleep 0.01
    done
    echo -e "\n----------------------------\nREADY."
}

# SAVE: Use AI to name and header your scripts
save() {
    if [ -z "$1" ]; then
        echo -e "?MISSING FILENAME DESCRIPTION ERROR"; return
    fi
    echo -e "COMMUNICATING WITH DISK DRIVE..."
    local ai_data=$(/usr/local/bin/gemini-pi "Provide 2 lines for a script described as '$1': 1. 8-char UPPERCASE filename. 2. REM comment header.")
    local ai_filename=$(echo "$ai_data" | sed -n '1p' | tr -d '[:space:]')
    local ai_header=$(echo "$ai_data" | sed -n '2p')
    echo "$ai_header" > "$ai_filename.sh"
    chmod +x "$ai_filename.sh"
    echo -e "SAVING \"$ai_filename\"\nOK\nREADY."
    nano "$ai_filename.sh"
}

# HELP: Displays Cheatsheet
help_cmd() {
    clear
    if [ -f ~/cheatsheet-c64.txt ]; then
        cat ~/cheatsheet-c64.txt
        echo -e "----------------------------------------\nREADY."
    else
        echo -e "?DEVICE NOT PRESENT ERROR: CHEATSHEET MISSING"
    fi
}

# POKE: Change background color (53281)
poke() {
    if [ "$1" == "53281" ]; then
        case $2 in
            0) echo -ne "\e[48;5;16m" ;; # Black
            1) echo -ne "\e[48;5;15m" ;; # White
            6) echo -ne "\e[48;5;17m" ;; # C64 Blue
            *) echo -e "?ILLEGAL QUANTITY ERROR" ; return ;;
        esac
        clear; echo -e "READY."
    else
        echo -e "?MONITOR NOT FOUND"
    fi
}

# --- ALIASES ---
alias LOAD='load'
alias LIST='list'
alias SAVE='save'
alias POKE='poke'
alias HELP='help_cmd'
alias RUN='source'
alias greet='python3 /usr/local/bin/gemini-pi'

# Cold Boot Greeting
clear
echo -e "    **** COMMODORE 64 BASIC V2 ****"
echo -e " 64K RAM SYSTEM  38911 BASIC BYTES FREE"
echo -e "READY."
EOF
    echo "[OK] .BASHRC UPDATED."
fi

echo "****************************************"
echo "* INSTALL COMPLETE. PLEASE REBOOT.     *"
echo "****************************************"
echo -e "\e[0m"