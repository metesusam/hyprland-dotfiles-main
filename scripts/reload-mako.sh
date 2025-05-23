#!/bin/bash

# Script to reload mako configuration

# Kill any running instances of mako
killall mako

# Start mako with the configuration
mako -c ~/.config/hypr/mako/config &

echo "Mako notification daemon restarted" 