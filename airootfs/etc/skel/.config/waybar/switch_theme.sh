#!/bin/bash

THEME_DIR="$HOME/.config/waybar/themes"
CONFIG_LINK="$HOME/.config/waybar/config"
STYLE_LINK="$HOME/.config/waybar/style.css"

# Get theme folders
themes=($(ls -1 "$THEME_DIR"))
current_config=$(readlink -f "$CONFIG_LINK")

# Detect current theme
for i in "${!themes[@]}"; do
    if [[ "$(readlink -f "$CONFIG_LINK")" == "$THEME_DIR/${themes[$i]}/config" ]]; then
        next_index=$(( (i + 1) % ${#themes[@]} ))
        break
    fi
done

next_theme="${themes[$next_index]}"

# Switch config and style
ln -sf "$THEME_DIR/$next_theme/config" "$CONFIG_LINK"
ln -sf "$THEME_DIR/$next_theme/style.css" "$STYLE_LINK"

# Restart Waybar
pkill waybar && nohup waybar >/dev/null 2>&1 &

# Optional: Notification
notify-send "Waybar Theme" "Switched to $next_theme"

