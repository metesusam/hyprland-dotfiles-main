#!/bin/bash
# Restart Waybar utility script
killall waybar 2>/dev/null || true
sleep 1
waybar &
disown
