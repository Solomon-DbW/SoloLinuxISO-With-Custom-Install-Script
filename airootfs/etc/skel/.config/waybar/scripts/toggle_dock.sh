#!/bin/bash

# Check if nwg-dock-hyprland is running
if pgrep -x "nwg-dock-hyprland" > /dev/null; then
    pkill -x "nwg-dock-hyprland"
else
    nohup nwg-dock-hyprland >/dev/null 2>&1 &
fi

