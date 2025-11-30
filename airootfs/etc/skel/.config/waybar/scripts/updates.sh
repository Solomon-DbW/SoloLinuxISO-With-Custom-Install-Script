#!/bin/bash

# Show number of updates
updates=$(checkupdates 2>/dev/null | wc -l)
echo "󰚰 $updates"

