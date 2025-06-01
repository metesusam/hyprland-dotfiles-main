#!/bin/bash

# Simple script to test mako notifications with different urgency levels

# Normal notification
notify-send "Normal Notification" "This is a normal notification example" 

# Low urgency notification
notify-send -u low "Low Urgency" "This is a low urgency notification example"

# Critical notification (stays until dismissed)
notify-send -u critical "Critical Notification" "This notification will stay until dismissed"

# Application specific (email category)
notify-send -c email "New Email" "You have received a new email message"

# With an icon
notify-send -i dialog-information "With Icon" "This notification has an icon"

echo "Sent test notifications" 
