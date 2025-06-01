#!/bin/bash
# Reset all workspaces utility script
for i in {1..10}; do
    hyprctl dispatch workspace $i
    hyprctl dispatch killactive
done
hyprctl dispatch workspace 1
