#!/bin/bash

# Usage: kitty_font_resize.sh [increase|decrease]

# Change amount
STEP=1

# Ask Kitty to change font size
if [ "$1" == "increase" ]; then
    kitty @ set-font-size +$STEP
elif [ "$1" == "decrease" ]; then
    kitty @ set-font-size -$STEP
else
    echo "Usage: $0 [increase|decrease]"
    exit 1
fi

