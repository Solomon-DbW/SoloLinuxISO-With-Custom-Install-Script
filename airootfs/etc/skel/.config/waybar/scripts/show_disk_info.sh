#!/bin/bash

# Get disk info (assuming root partition is on /)
disk_info=$(df -h / | awk 'NR==2')
total=$(echo $disk_info | awk '{print $2}')
used=$(echo $disk_info | awk '{print $3}')
avail=$(echo $disk_info | awk '{print $4}')
percent=$(echo $disk_info | awk '{print $5}')

# Send notification
notify-send "Disk Usage" "Total: $total\nUsed: $used\nAvailable: $avail\nUsage: $percent"

