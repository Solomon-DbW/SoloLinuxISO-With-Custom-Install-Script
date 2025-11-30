#!/bin/bash

# Define the full, absolute path to the wallpapers directory
WALLPAPER_DIR="~/.config/hypr/wallpapers"

# Execute waypaper with the correct flag and path
# Use the full path for waypaper if it's not in your $PATH
# Otherwise, just use 'waypaper'
waypaper --folder "$WALLPAPER_DIR"

# If you know the full path to waypaper (e.g., /usr/bin/waypaper), use that:
# /usr/bin/waypaper --folder "$WALLPAPER_DIR"
