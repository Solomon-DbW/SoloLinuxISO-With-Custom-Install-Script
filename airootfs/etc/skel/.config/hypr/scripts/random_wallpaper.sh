#!/bin/bash

# Path to wallpaper directory
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

# Time interval between changes (in seconds)
INTERVAL=120

# Kill any existing hyprpaper instances
pkill hyprpaper 2>/dev/null

# Start hyprpaper in the background
hyprpaper &

# Give hyprpaper time to start
sleep 1

# Infinite loop to change wallpapers
while true; do
    RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

    # Preload the random wallpaper
    hyprctl hyprpaper preload "$RANDOM_WALLPAPER"

    # Set it on your laptop display (change eDP-1 if needed)
    hyprctl hyprpaper wallpaper "eDP-1,$RANDOM_WALLPAPER"

    # Log the change (optional)
    echo "$(date): Set wallpaper to $RANDOM_WALLPAPER" >> ~/.config/hypr/wallpaper.log

    # Wait before changing again
    sleep "$INTERVAL"
done

