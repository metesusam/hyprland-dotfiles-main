#!/bin/bash

# Script to restart Waybar when it gets buggy
# Usage: restart_waybar.sh [force]
# If "force" is provided as parameter, it will use SIGKILL instead of SIGTERM

# First, try to terminate all Waybar instances
if [[ "$1" == "force" ]]; then
    # Force kill with SIGKILL (-9)
    killall -9 waybar 2>/dev/null
else
    # Normal kill with SIGTERM
    killall waybar 2>/dev/null
fi

# Wait a moment to ensure processes are terminated
sleep 0.5

# Check if Waybar is still running
if pgrep -x waybar >/dev/null; then
    # If still running, try force kill
    echo "Waybar still running. Using force kill..."
    killall -9 waybar 2>/dev/null
    sleep 0.5
fi

# Start Waybar
echo "Starting Waybar..."
waybar &

echo "Waybar restart complete." 