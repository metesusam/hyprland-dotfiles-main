#!/usr/bin/env python3

import argparse
import json
import os
import sys
import signal
import gi
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib

# List of players to prioritize
PLAYERS = ["spotify", "firefox", "chromium", "mpv", "vlc"]

def signal_handler(sig, frame):
    sys.stdout.write(json.dumps({"text": ""}) + "\n")
    sys.stdout.flush()
    sys.exit(0)

class MediaPlayer:
    def __init__(self, player_name):
        self.player_name = player_name
        self.player = Playerctl.Player.new_from_name(player_name)
        self.player.connect('metadata', self.on_metadata)
        self.player.connect('playback-status', self.on_playback_status)
        self.status = 'stopped'

        # Initial state
        metadata = self.player.get_metadata()
        self.artist = self.get_artist(metadata)
        self.title = self.get_title(metadata)
        self.album = self.get_album(metadata)
        self.status = self.player.get_property('playback-status')
        
        self.update_display()

    def get_artist(self, metadata):
        try:
            return metadata.get_string('xesam:artist')
        except (TypeError, GLib.Error):
            return ""

    def get_title(self, metadata):
        try:
            return metadata.get_string('xesam:title')
        except (TypeError, GLib.Error):
            return ""

    def get_album(self, metadata):
        try:
            return metadata.get_string('xesam:album')
        except (TypeError, GLib.Error):
            return ""

    def on_metadata(self, player, metadata):
        self.artist = self.get_artist(metadata)
        self.title = self.get_title(metadata)
        self.album = self.get_album(metadata)
        self.update_display()

    def on_playback_status(self, player, status):
        self.status = status
        self.update_display()

    def update_display(self):
        if self.status == 'Playing' and self.title:
            text = self.format_output()
            output = {
                "text": text,
                "class": self.player_name,
                "alt": self.player_name,
                "tooltip": f"{self.artist} - {self.title}\n{self.album}",
            }
        else:
            output = {"text": ""}
        
        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def format_output(self):
        # Format the output: limit to 30 chars total
        # If there's artist and title, prefer "Artist - Title"
        # Otherwise just show Title
        if self.artist and self.title:
            result = f"{self.artist} - {self.title}"
            if len(result) > 30:
                result = result[:27] + "..."
        elif self.title:
            result = self.title
            if len(result) > 30:
                result = result[:27] + "..."
        else:
            result = "Playing"
        return result

def find_active_player():
    # Try to find first available player from priority list
    for name in PLAYERS:
        try:
            player = MediaPlayer(name)
            if player.status == 'Playing':
                return player
        except GLib.Error:
            continue

    # If no prioritized player, check what's available
    try:
        managers = Playerctl.list_players()
        if managers:
            return MediaPlayer(managers[0].name)
    except GLib.Error:
        pass
    
    # No active players found
    return None

def main():
    # Set up signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # Initial empty output
    sys.stdout.write(json.dumps({"text": ""}) + "\n")
    sys.stdout.flush()

    try:
        player = find_active_player()
        if player:
            # Main loop
            loop = GLib.MainLoop()
            loop.run()
        else:
            # No active player found
            sys.stdout.write(json.dumps({"text": ""}) + "\n")
            sys.stdout.flush()
    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
        sys.exit(1)

if __name__ == "__main__":
    main() 