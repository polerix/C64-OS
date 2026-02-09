# **** C64-OS USER'S GUIDE ****

### FOR THE RASPBERRY PI 5 COMPUTING SYSTEM

**COPYRIGHT (C) 2026 BY POLERIX DIGITAL SYSTEMS**
**ALL RIGHTS RESERVED**

---

## 1. INTRODUCTION

Congratulations! You have just purchased (or built) the **C64-OS**, a sophisticated software overlay designed to transform your high-performance Raspberry Pi 5 into a fully functional, AI-enhanced Commodore 64 environment.

This system bridges the gap between the classic 8-bit user experience and the modern era of Generative Artificial Intelligence.

---

## 2. SYSTEM STARTING PROCEDURE

Once the installation script is executed, your system will automatically initialize into the **C64-OS** environment upon every login.

1. **COLOR DISPLAY:** The screen will transition to the classic 16-color "Light Blue on Dark Blue" palette.
2. **CURSOR:** The standard line cursor is replaced by the authentic **BLOCK CURSOR**.
3. **GEMINI INTERFACE:** The system performs a handshake with the Gemini 2.0 Flash-Lite model via the `/usr/local/bin/gemini-pi` bridge.

---

## 3. KEYBOARD COMMANDS

The C64-OS supports several high-level BASIC-style commands. Note: All commands should be entered in **UPPERCASE** for maximum authenticity.

### LOAD "NAME"

The `LOAD` command is used to retrieve data or activate system modules.

* `LOAD "GEMINI"` : Initializes a real-time conversational session with the onboard AI.
* `LOAD "C64"`    : Fires the VICE Emulator for cycle-exact 1982 software execution.

### LIST

Unlike the original BASIC `LIST`, this command uses the AI to scan your current storage blocks. It will provide a natural language summary of your most recently modified files and programs.

### SAVE "DESCRIPTION"

To save a new program, simply describe it. The AI will:

1. Calculate an 8-character filename.
2. Generate a BASIC `REM` header.
3. Initialize the file and open the editor.

---

## 4. TROUBLESHOOTING (ERROR MESSAGES)

* **?DEVICE NOT PRESENT ERROR** : Check your internet connection. The Gemini AI requires a link to the mainframe.
* **?FILE NOT FOUND ERROR** : You have attempted to `LOAD` a module not recognized by the kernel.
* **RESOURCES EXHAUSTED** : You have exceeded your daily quota of "Thinking" units. Wait 60 seconds for the capacitors to recharge.

---

## 5. TECHNICAL SPECIFICATIONS

* **BRAIN:** Google Gemini 2.0 Flash-Lite (Cloud-Integrated)
* **HEART:** Raspberry Pi 5 Model B (8GB RAM)
* **STORAGE:** Simulated 1541 Disk Drive (Linux Filesystem)
* **DISPLAY:** ANSI/VT100 Emulation

---

**READY.**
