# ~/.bashrc: C64-OS ENHANCED EDITION
# FOR RASPBERRY PI 5 / WAVESHARE V1

# --- STANDARD BASH OVERHEAD ---
case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
force_color_prompt=yes

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# --- C64-OS PALETTE & VISUALS ---
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
    # ... mapped mainly to ensure blues are correct
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
# If we are in shellinabox (often TERM=xterm) and NOT inside tmux already
if [[ "$TERM" == "xterm" || "$TERM" == "xterm-color" ]] && [[ -z "$TMUX" ]]; then
   # Optional: Only auto-start if a flag file exists or user checks 'Kiosk Mode'
   # For now, we provide the alias 'c64' to launch it manually, or user can add to .bash_profile
   alias c64="$HOME/c64-os/c64_tmux.sh"
fi

# --- C64-OS CORE ENGINE ---

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

# HELP: Displays Cheatsheet + PiSugar Battery Status
help_cmd() {
    clear
    if [ -f ~/cheatsheet-c64.txt ]; then
        cat ~/cheatsheet-c64.txt
        echo -e "----------------------------------------"
        # PiSugar 3 Battery Check
        if command -v curl &> /dev/null; then
            BATTERY=$(curl -s http://127.0.0.1:8421/get battery | grep -oP '\d+' | head -1)
            if [ ! -z "$BATTERY" ]; then
                echo -e "BATTERY STATUS: $BATTERY% CAPACITORS CHARGED"
            else
                echo -e "BATTERY STATUS: AC POWER DETECTED"
            fi
        fi
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

# DASH: Send text specifically to the Waveshare Screen
dash() {
    echo -ne "\e[48;5;${C64_BG:-17}m\e[38;5;${C64_FG:-147}m\e[1;1H\e[2J$1" > /dev/tty1
}

# --- ALIASES ---
alias LOAD='load'
alias LIST='list'
alias SAVE='save'
alias POKE='poke'
alias DASH='dash'
alias HELP='help_cmd'
alias RUN='source'
alias greet='python3 /usr/local/bin/gemini-pi'

# --- DASHBOARD COMMANDS ---
# Starts the background telemetry loop
alias DASH_ON='nohup bash ~/c64_dash.sh > /dev/null 2>&1 &'
# Stops the background loop
alias DASH_OFF='pkill -f c64_dash.sh'

# Cold Boot Greeting
clear
echo -e "    **** COMMODORE 64 BASIC V2 ****"
echo -e " 64K RAM SYSTEM  38911 BASIC BYTES FREE"
echo -e "READY."