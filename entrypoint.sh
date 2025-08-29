
#!/bin/bash
set -e

# Start a virtual X server
Xvfb :0 -screen 0 1280x800x24 &
sleep 2

# Window manager
fluxbox &

# Start x11vnc to expose that display
x11vnc -display :0 -forever -nopw -rfbport 5900 -shared &

# Start noVNC on port 8080 — will serve its own HTML client
websockify --web=/usr/share/novnc 8080 localhost:5900 &

# Start Android Emulator inside this virtual screen
emulator -avd test -no-audio -no-boot-anim -gpu swiftshader_indirect -no-snapshot -verbose
