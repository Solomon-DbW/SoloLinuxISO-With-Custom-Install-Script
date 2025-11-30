#!/bin/bash

kitty --class system_update sh -c '
echo "Run full system update? (y/n)"
read -r choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    sudo pacman -Syu
else
    echo "Update cancelled."
fi
echo "Press Enter to exit..."
read
'

