#!/bin/bash

if ! pgrep -x "nwg-dock-hyprland" > /dev/null; then
    nohup nwg-dock-hyprland >/dev/null 2>&1 &
fi

