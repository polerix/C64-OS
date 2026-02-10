#!/bin/bash
# Helper for c64_tmux.sh - fills pane with solid color
export PS1=""
# Sets background color to standard C64 Blue (ANSI 48;5;17 or similar depending on palette)
# Using generic ANSI for compatibility, palette in .bashrc will fix exact shade
printf '\033[48;5;147m' 
# Print spaces to fill
printf ' %.0s' {1..5000}
clear
# Trap to keep script running
while true; do sleep 1000; done
