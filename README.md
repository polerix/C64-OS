# **** C64-OS USER'S GUIDE ****

### FOR THE RASPBERRY PI 5 COMPUTING SYSTEM

**COPYRIGHT (C) 2026 BY POLERIX DIGITAL SYSTEMS**
**ALL RIGHTS RESERVED**

---

## 1. INTRODUCTION

Congratulations! You have just purchased (or built) the **C64-OS**, a sophisticated software overlay designed to transform your high-performance Raspberry Pi 5 into a fully functional, AI-enhanced Commodore 64 environment.

This system bridges the gap between the classic 8-bit user experience and the modern era of Generative Artificial Intelligence.

---

## 2. INSTALLATION

To deploy the C64-OS kernel on a Raspberry Pi 5:

```bash
git clone https://github.com/polerix/C64-OS.git
cd C64-OS
chmod +x install.sh
./install.sh
```

**What the Installer Does:**
*   Installs dependencies: `vice`, `python3-requests`, `shellinabox`, `tmux`, `plymouth`, `fbi`.
*   Secures your Gemini API Key in `~/.gemini_key`.
*   Deploys the **C64 Kiosk Server** and **AI Bridge**.
*   Configures the system for the Waveshare 3.5" v1 Display (SPI timing fixes).
*   Configures `shellinabox` to provide a web-based terminal.

---

## 3. KIOSK MODE & WEB INTERFACE

The heart of the C64-OS experience is the **Kiosk Dashboard**, accessible by running `./c64_dash.sh` (or auto-starting it). It features a retro-styled Tabbed Interface:

### TAB 1: TERMINAL VIEW (ShellInABox)
A live, interactive terminal session embedded directly in the dashboard.
*   **Authentic Visuals**: Implements the correct C64 Color Palette (Blue/Light Blue) via `.bashrc` injection.
*   **Border Emulation**: Wraps the shell in a 7-pane `tmux` layout to simulate the classic C64 border.

### TAB 2: CONTROL PANEL
A graphical configuration menu for the system.
*   **AI Configuration**: Select your AI provider (Gemini Default) and securely save API keys.
*   **Visual Theme**: Toggle between Classic Blue, Matrix Green, and Amber themes.
*   **Command Editor**: Map custom keywords to shell commands.

---

## 4. KEYBOARD COMMANDS

The C64-OS supports several high-level BASIC-style commands in the terminal (ensure standard caps lock is NOT required, but commands are stylized in uppercase).

### LOAD "NAME"
* `LOAD "GEMINI"` : Initializes a real-time conversational session with the onboard AI.
* `LOAD "C64"`    : Fires the VICE Emulator for cycle-exact 1982 software execution.

### LIST
Analyzes the "Storage Map" using Gemini AI. It provides a natural language summary of your most recently modified files.

### SAVE "DESCRIPTION"
Describe a script, and the AI will calculate an 8-character filename, generate a `REM` header, and open the editor for you.

---

## 5. TECHNICAL SPECIFICATIONS

* **BRAIN:** Google Gemini 2.0 Flash-Lite (via Python Bridge)
* **HEART:** Raspberry Pi 5 Model B (8GB RAM)
* **INTERFACE:** HTML5 Kiosk with Python `http.server` Backend
* **TERMINAL:** `shellinabox` with `tmux` Border Emulation
* **DISPLAY:** Supports HDMI & Waveshare SPI Screens

---

**READY.**