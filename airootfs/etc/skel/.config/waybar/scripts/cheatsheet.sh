#!/bin/bash
# Copied from https://github.com/JaKooLit/Hyprland-Dots/blob/main/config/hypr/scripts/KeyHints.sh

# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland

# --- NEW LOGIC TO CHECK FOR DARK THEME ---
# Check the preferred color scheme setting
COLOR_SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)

# Set a variable for the GTK theme environment override
GTK_THEME_OVERRIDE=""

# If the color scheme is set to prefer-dark, explicitly set a dark theme for yad
if [[ "$COLOR_SCHEME" == "'prefer-dark'" ]]; then
  # Use a theme that has a dark variant. Adwaita:dark is a common choice.
  # You might need to change 'Adwaita:dark' to match a dark theme installed on your system.
  GTK_THEME_OVERRIDE="Adwaita:dark"
fi
# ------------------------------------------

# Check if rofi or yad is running and kill them if they are
if pidof rofi > /dev/null; then
  pkill rofi
fi

if pidof yad > /dev/null; then
  pkill yad
fi

# Launch yad with calculated width and height
# We prepend the GDK_BACKEND and the new GTK_THEME_OVERRIDE
GDK_BACKEND=$BACKEND GTK_THEME="$GTK_THEME_OVERRIDE" yad \
    --center \
    --title="SoloLInux Hyprland Keybindings Cheat Sheet" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
"ESC" "close tt" "" " = " "SUPER KEY (Windows Key Button)" "(SUPER KEY)" \
"Prt SC " "Screenshot entire workspace" "(hyprshot -m output)" \
"SHIFT Prt SC " "Screenshot window" "(hyprshot -m window)" \
" Prt SC " "Screenshot selected region" "(hyprshot -m region)" \
" SHIFT K" "Searchable Keybinds" "(Search all Keybinds via rofi)" \
" SHIFT E" "KooL Hyprland Settings Menu" "" \
"" "" "" \
" S" "Terminal" "(kitty)" \
" B" "Launch Browser" "(brave)" \
" R" "Application Launcher" "(rofi-wayland)" \
" E" "Open Emacs" "(emacs)" \
" Q" "close active window" "(not kill)" \
" Shift Q " "kills an active window" "(kill)" \
" ALT mouse scroll up/down   " "Desktop Zoom" "Desktop Magnifier" \
" Alt V" "Clipboard Manager" "(cliphist)" \
" c" "Cycle wallpaper" "(hyprpaper)" \
" w" "Choose wallpaper" "(waypaper)" \
" CTRL ALT B" "Hide/UnHide Waybar" "waybar" \
" T" "Choose waybar styles" "(waybar styles)" \
" SHIFT N" "Launch Notification Panel" "swaync Notification Center" \
" Print" "screenshot" "(grim)" \
" CTRL Print" "screenshot timer 5 secs " "(grim)" \
" CTRL SHIFT Print" "screenshot timer 10 secs " "(grim)" \
"ALT Print" "Screenshot active window" "active window only" \
"CTRL ALT P" "power-menu" "(wlogout)" \
"CTRL ALT L" "screen lock" "(hyprlock)" \
"CTRL ALT Del" "Hyprland Exit" "(NOTE: Hyprland Will exit immediately)" \
" SHIFT F" "Fullscreen" "Toggles to full screen" \
" CTL F" "Fake Fullscreen" "Toggles to fake full screen" \
" ALT L" "Toggle Dwindle | Master Layout" "Hyprland Layout" \
" SPACEBAR" "Toggle float" "single window" \
" ALT SPACEBAR" "Toggle all windows to float" "all windows" \
" ALT O" "Toggle Blur" "normal or less blur" \
" CTRL O" "Toggle Opaque ON or OFF" "on active window only" \
" Shift A" "Animations Menu" "Choose Animations via rofi" \
" CTRL R" "Rofi Themes Menu" "Choose Rofi Themes via rofi" \
" CTRL Shift R" "Rofi Themes Menu v2" "Choose Rofi Themes via Theme Selector (modified)" \
" SHIFT G" "Gamemode! All animations OFF or ON" "toggle" \
" ALT E" "Rofi Emoticons" "Emoticon" \
" H" "Launch this Quick Cheat Sheet" "" \
"" "" "" \
# "More tips:" "https://github.com/JaKooLit/Hyprland-Dots/wiki" ""
