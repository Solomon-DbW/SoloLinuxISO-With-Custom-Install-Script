# Install SoloLinux GUI configurations from AUR
echo "Installing SoloLinux GUI configurations..."
yay -S --noconfirm sololinux-gui

# For existing users, copy from /etc/skel
echo "Applying configurations to current user..."
cp -r /etc/skel/.config/* ~/.config/ 2>/dev/null || true
cp /etc/skel/.tmux.conf ~/ 2>/dev/null || true
cp /etc/skel/.zshrc ~/ 2>/dev/null || true
