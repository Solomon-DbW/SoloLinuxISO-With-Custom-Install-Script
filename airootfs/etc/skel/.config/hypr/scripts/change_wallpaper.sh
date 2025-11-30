#!/bin/bash

# Hyprpaper Wallpaper Changer
# This script cycles through wallpapers chronologically from a specified folder

# Configuration
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
HYPR_CONFIG="$HOME/.config/hypr/hyprpaper.conf"
LAST_WALLPAPER_FILE="$HOME/.cache/last_wallpaper"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory not found at $WALLPAPER_DIR"
    echo "Please create this directory or edit the script to point to your wallpaper location."
    exit 1
fi

# Check if hyprpaper is running, if not start it
ensure_hyprpaper_running() {
    if ! pgrep -x "hyprpaper" > /dev/null; then
        echo "Starting hyprpaper..."
        hyprpaper &
        sleep 1 # Give it a moment to start
    fi
}

# Get all wallpapers and sort them alphabetically
get_all_wallpapers() {
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.avif" \) | sort
}

# Set wallpaper for all monitors
set_wallpaper() {
    local wallpaper="$1"
    local retry_count=0
    local max_retries=3
    
    ensure_hyprpaper_running
    
    # Try to unload all previous wallpapers
    hyprctl hyprpaper unload all 2>/dev/null || true
    
    # First, preload the wallpaper with retries
    echo "Preloading: $wallpaper"
    while [ $retry_count -lt $max_retries ]; do
        if hyprctl hyprpaper preload "$wallpaper" 2>/dev/null; then
            echo "Preload successful"
            break
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                echo "Preload failed, restarting hyprpaper and retrying ($retry_count/$max_retries)..."
                killall -q hyprpaper
                sleep 1
                hyprpaper &
                sleep 2
            else
                echo "Failed to preload after $max_retries attempts."
            fi
        fi
    done
    
    # Reset for setting wallpaper
    retry_count=0
    
    # Get list of all monitors
    MONITORS=$(hyprctl monitors -j | jq -r '.[].name')
    
    # Set the wallpaper for each monitor
    for monitor in $MONITORS; do
        echo "Setting wallpaper for monitor: $monitor"
        while [ $retry_count -lt $max_retries ]; do
            if hyprctl hyprpaper wallpaper "$monitor,$wallpaper" 2>/dev/null; then
                echo "Wallpaper set successfully for $monitor"
                break
            else
                retry_count=$((retry_count + 1))
                if [ $retry_count -lt $max_retries ]; then
                    echo "Setting wallpaper failed, restarting hyprpaper and retrying ($retry_count/$max_retries)..."
                    killall -q hyprpaper
                    sleep 1
                    hyprpaper &
                    sleep 2
                    hyprctl hyprpaper preload "$wallpaper" 2>/dev/null
                else
                    echo "Failed to set wallpaper after $max_retries attempts."
                fi
            fi
        done
        retry_count=0 # Reset for next monitor
    done
    
    # Save the current wallpaper path for next time
    mkdir -p "$(dirname "$LAST_WALLPAPER_FILE")"
    echo "$wallpaper" > "$LAST_WALLPAPER_FILE"
    
    echo "Wallpaper set to: $(basename "$wallpaper")"
}

# Main execution
wallpapers=($(get_all_wallpapers))

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "Error: No wallpapers found in $WALLPAPER_DIR"
    echo "Please add some image files (jpg, jpeg, png, webp, or avif) to this directory."
    exit 1
fi

# Find current index or start at 0
current_index=0
if [ -f "$LAST_WALLPAPER_FILE" ]; then
    last_wallpaper=$(cat "$LAST_WALLPAPER_FILE")
    for i in "${!wallpapers[@]}"; do
        if [ "${wallpapers[$i]}" = "$last_wallpaper" ]; then
            current_index=$((i+1))
            break
        fi
    done
    
    # Loop back to beginning if we reached the end
    if [ $current_index -ge ${#wallpapers[@]} ]; then
        current_index=0
    fi
fi

# Set the next wallpaper
set_wallpaper "${wallpapers[$current_index]}"

exit 0
