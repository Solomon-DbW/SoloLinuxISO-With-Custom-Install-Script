#!/bin/bash

if pgrep -x "nwg-dock-hyprland" > /dev/null; then
    echo '{"text": "", "class": "dock-running"}'
else
    echo '{"text": "", "class": "dock-off"}'
fi

