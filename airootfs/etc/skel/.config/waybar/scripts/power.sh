#!/bin/bash

#!/bin/bash

# Define options for the Rofi menu
options=" Lock\n Logout\n Reboot\n Shutdown\n Suspend"

# Show Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -p "Power Menu" -theme-str 'window { width: 250px; }')

# Execute selected action
case "$chosen" in
    " Lock") hyprlock ;;
    " Logout") hyprctl dispatch exit ;;
    " Reboot") systemctl reboot ;;
    " Shutdown") systemctl poweroff ;;
    " Suspend") systemctl suspend ;;
    *) exit 1 ;;
esac

# esac

