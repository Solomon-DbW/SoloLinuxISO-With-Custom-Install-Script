#!/bin/bash
set -e

### ==========================================
### COLORS AND STYLING
### ==========================================
SL_COLOR="\e[38;2;37;104;151m"
SL_BOLD="\e[1m"
SL_RESET="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"

### ==========================================
### HELPER FUNCTIONS
### ==========================================
print_header() {
    clear
    echo -e "${SL_COLOR}${SL_BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                   ║"
    echo "║                   SoloLinux Installation                          ║"
    echo "║                                                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${SL_RESET}"
}

print_section() {
    echo ""
    echo -e "${SL_COLOR}${SL_BOLD}┌─ $1 ─────────────────────────────────────${SL_RESET}"
}

print_step() {
    echo -e "${CYAN}  ➜${SL_RESET} $1"
}

print_success() {
    echo -e "${GREEN}  ✔${SL_RESET} $1"
}

print_error() {
    echo -e "${RED}  ✘${SL_RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}  ⚠${SL_RESET} $1"
}

print_info() {
    echo -e "${BLUE}  ℹ${SL_RESET} $1"
}

prompt_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [ -n "$default" ]; then
        echo -ne "${SL_COLOR}  →${SL_RESET} $prompt [${CYAN}$default${SL_RESET}]: "
    else
        echo -ne "${SL_COLOR}  →${SL_RESET} $prompt: "
    fi
    
    read -r input
    eval "$var_name=\"${input:-$default}\""
}

prompt_password() {
    local prompt="$1"
    local var_name="$2"
    
    echo -ne "${SL_COLOR}  →${SL_RESET} $prompt: "
    read -rs input
    echo ""
    eval "$var_name=\"$input\""
}

prompt_confirm() {
    local prompt="$1"
    echo -ne "${YELLOW}  ⚠${SL_RESET} $prompt [y/N]: "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

show_progress() {
    local current="$1"
    local total="$2"
    local description="$3"
    
    echo ""
    echo -e "${SL_COLOR}${SL_BOLD}Progress: [$current/$total]${SL_RESET} $description"
    
    # Simple progress bar
    local filled=$((current * 50 / total))
    local empty=$((50 - filled))
    printf "${SL_COLOR}  ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "]${SL_RESET}\n"
}

### ==========================================
### CHECK ROOT
### ==========================================
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root."
    exit 1
fi

### ==========================================
### MAIN MENU
### ==========================================
print_header

print_section "System Information"
if [[ -d /sys/firmware/efi ]]; then
    BOOTMODE="UEFI"
    print_info "Boot mode: ${GREEN}UEFI${SL_RESET}"
else
    BOOTMODE="BIOS"
    print_info "Boot mode: ${YELLOW}BIOS/Legacy${SL_RESET}"
fi

### ==========================================
### DISK SELECTION
### ==========================================
print_section "Disk Selection"
print_step "Detecting available disks..."

DISKS=($(lsblk -dno NAME,TYPE,SIZE | awk '
  $2=="disk" {
    gsub("G","",$3)
    if ($3 >= 30) print $1
  }'))

if [ ${#DISKS[@]} -eq 0 ]; then
    print_error "No suitable install disk found (minimum 30GB required)"
    lsblk
    exit 1
fi

echo ""
echo -e "${SL_COLOR}${SL_BOLD}  Available Disks:${SL_RESET}"
echo ""

for i in "${!DISKS[@]}"; do
    SIZE=$(lsblk -dno SIZE /dev/${DISKS[$i]} | head -1)
    MODEL=$(lsblk -dno MODEL /dev/${DISKS[$i]} | head -1 || echo "Unknown")
    echo -e "  ${CYAN}[$i]${SL_RESET} /dev/${DISKS[$i]} - $SIZE - $MODEL"
done

echo ""
prompt_input "Select disk by index" "0" "DISKIDX"

if [[ ! "$DISKIDX" =~ ^[0-9]+$ ]] || [ "$DISKIDX" -ge "${#DISKS[@]}" ]; then
    print_error "Invalid selection"
    exit 1
fi

DISK="/dev/${DISKS[$DISKIDX]}"
print_success "Selected: ${CYAN}$DISK${SL_RESET}"

echo ""
print_warning "ALL DATA ON $DISK WILL BE PERMANENTLY ERASED!"
echo -ne "${RED}${SL_BOLD}  Type 'WIPE' to confirm: ${SL_RESET}"
read -r CONFIRM

if [[ "$CONFIRM" != "WIPE" ]]; then
    print_info "Installation cancelled"
    exit 1
fi

### ==========================================
### USER CONFIGURATION
### ==========================================
print_section "User Configuration"

prompt_input "Hostname" "sololinux" "HOSTNAME"
prompt_input "Username" "solo" "USERNAME"

while true; do
    prompt_password "Password for $USERNAME" "PASSWORD1"
    prompt_password "Confirm password" "PASSWORD2"
    
    if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
        print_success "Password confirmed"
        break
    else
        print_error "Passwords do not match. Try again."
    fi
done

while true; do
    prompt_password "Root password" "ROOT1"
    prompt_password "Confirm root password" "ROOT2"
    
    if [[ "$ROOT1" == "$ROOT2" ]]; then
        print_success "Root password confirmed"
        break
    else
        print_error "Passwords do not match. Try again."
    fi
done

echo ""
if prompt_confirm "Grant sudo privileges to $USERNAME?"; then
    SUDOOPT="y"
    print_success "User will have sudo privileges"
else
    SUDOOPT="n"
    print_info "User will not have sudo privileges"
fi

echo ""
if prompt_confirm "Enable LUKS disk encryption?"; then
    ENCRYPT="y"
    print_success "Encryption will be enabled"
else
    ENCRYPT="n"
    print_info "Encryption will be disabled"
fi

### ==========================================
### INSTALLATION SUMMARY
### ==========================================
print_section "Installation Summary"
echo ""
echo -e "  ${SL_COLOR}Disk:${SL_RESET}       $DISK"
echo -e "  ${SL_COLOR}Hostname:${SL_RESET}   $HOSTNAME"
echo -e "  ${SL_COLOR}Username:${SL_RESET}   $USERNAME"
echo -e "  ${SL_COLOR}Sudo:${SL_RESET}       $([ "$SUDOOPT" == "y" ] && echo "Yes" || echo "No")"
echo -e "  ${SL_COLOR}Encrypted:${SL_RESET}  $([ "$ENCRYPT" == "y" ] && echo "Yes" || echo "No")"
echo -e "  ${SL_COLOR}Boot mode:${SL_RESET}  $BOOTMODE"
echo ""

if ! prompt_confirm "Begin installation?"; then
    print_info "Installation cancelled"
    exit 1
fi

### ==========================================
### PARTITIONING
### ==========================================
show_progress 1 7 "Partitioning disk"
sleep 1

if [[ "$BOOTMODE" == "UEFI" ]]; then
    parted --script "$DISK" mklabel gpt
    parted --script "$DISK" mkpart ESP fat32 1MiB 301MiB
    parted --script "$DISK" set 1 boot on
    parted --script "$DISK" mkpart primary linux-swap 301MiB 4297MiB
    parted --script "$DISK" mkpart primary ext4 4297MiB 100%
    
    if [[ "$DISK" =~ "nvme" ]]; then
        PESP="${DISK}p1"
        PSWAP="${DISK}p2"
        PROOT="${DISK}p3"
    else
        PESP="${DISK}1"
        PSWAP="${DISK}2"
        PROOT="${DISK}3"
    fi
else
    parted --script "$DISK" mklabel msdos
    parted --script "$DISK" mkpart primary ext4 1MiB 101MiB
    parted --script "$DISK" set 1 boot on
    parted --script "$DISK" mkpart primary linux-swap 101MiB 4197MiB
    parted --script "$DISK" mkpart primary ext4 4197MiB 100%
    
    if [[ "$DISK" =~ "nvme" ]]; then
        P1="${DISK}p1"
        PSWAP="${DISK}p2"
        PROOT="${DISK}p3"
    else
        P1="${DISK}1"
        PSWAP="${DISK}2"
        PROOT="${DISK}3"
    fi
fi

print_success "Partitioning complete"

### ==========================================
### FORMATTING
### ==========================================
show_progress 2 7 "Formatting partitions"

if [[ "$BOOTMODE" == "UEFI" ]]; then
    mkfs.fat -F32 "$PESP" > /dev/null 2>&1
else
    mkfs.ext4 -F "$P1" > /dev/null 2>&1
fi

mkswap "$PSWAP" > /dev/null 2>&1

if [[ "$ENCRYPT" == "y" ]]; then
    print_step "Setting up encryption..."
    echo -n "$PASSWORD1" | cryptsetup luksFormat "$PROOT" - 
    echo -n "$PASSWORD1" | cryptsetup open "$PROOT" soloroot -
    mkfs.ext4 -F /dev/mapper/soloroot > /dev/null 2>&1
    ROOT_MAPPER="/dev/mapper/soloroot"
else
    mkfs.ext4 -F "$PROOT" > /dev/null 2>&1
    ROOT_MAPPER="$PROOT"
fi

print_success "Formatting complete"

### ==========================================
### MOUNTING
### ==========================================
show_progress 3 7 "Mounting filesystems"

mount "$ROOT_MAPPER" /mnt

if [[ "$BOOTMODE" == "UEFI" ]]; then
    mkdir -p /mnt/boot/efi
    mount "$PESP" /mnt/boot/efi
else
    mkdir -p /mnt/boot
    mount "$P1" /mnt/boot
fi

swapon "$PSWAP"

print_success "Filesystems mounted"

### ==========================================
### STAGE SCRIPTS
### ==========================================
show_progress 4 7 "Staging post-install scripts"

mkdir -p /mnt/home/"$USERNAME"
cp /root/solo_gui_setup.sh /mnt/home/"$USERNAME"/ 2>/dev/null || true

mkdir -p /mnt/usr/local/bin
cp /root/slpm /mnt/usr/local/bin/
chmod +x /mnt/usr/local/bin/slpm

chown 1000:1000 /mnt/home/"$USERNAME"/solo_gui_setup.sh 2>/dev/null || true
chmod +x /mnt/home/"$USERNAME"/solo_gui_setup.sh 2>/dev/null || true

print_success "Scripts staged"

### ==========================================
### INSTALL BASE SYSTEM
### ==========================================
show_progress 5 7 "Installing base system (this may take several minutes)"

pacstrap /mnt base linux linux-firmware grub efibootmgr sudo networkmanager nano vim

print_success "Base system installed"

### ==========================================
### GENERATE FSTAB
### ==========================================
show_progress 6 7 "Generating filesystem table"

genfstab -U /mnt >> /mnt/etc/fstab

print_success "Filesystem table generated"

### ==========================================
### CONFIGURE SYSTEM
### ==========================================
show_progress 7 7 "Configuring system"

arch-chroot /mnt /bin/bash <<CHROOT_EOF
set -e

HOSTNAME='$HOSTNAME'
USERNAME='$USERNAME'
PASSWORD1='$PASSWORD1'
ROOT1='$ROOT1'
SUDOOPT='$SUDOOPT'
BOOTMODE='$BOOTMODE'
DISK='$DISK'
ENCRYPT='$ENCRYPT'
PROOT='$PROOT'

# Timezone and locale
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/' /etc/locale.gen
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_GB.UTF-8' > /etc/locale.conf

# Network configuration
echo "\$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 \$HOSTNAME.localdomain \$HOSTNAME
EOF

# Set root password
echo "root:\$ROOT1" | chpasswd

# Create user
if [[ "\$SUDOOPT" == "y" ]]; then
    useradd -m -G wheel -s /bin/bash "\$USERNAME"
    echo "\$USERNAME:\$PASSWORD1" | chpasswd
    mkdir -p /etc/sudoers.d
    echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/10-wheel
    chmod 440 /etc/sudoers.d/10-wheel
else
    useradd -m -s /bin/bash "\$USERNAME"
    echo "\$USERNAME:\$PASSWORD1" | chpasswd
fi

chown -R "\$USERNAME":"\$USERNAME" /home/"\$USERNAME"

# Enable NetworkManager
systemctl enable NetworkManager

# Configure encryption
if [[ "\$ENCRYPT" == "y" ]]; then
    ROOTUUID=\$(blkid -s UUID -o value "\$PROOT")
    sed -i "s/^HOOKS=.*/HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)/" /etc/mkinitcpio.conf
    mkinitcpio -P
    sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=\$ROOTUUID:soloroot root=/dev/mapper/soloroot\"|" /etc/default/grub
fi

# Create SoloLinux identity
cat > /etc/os-release <<'OS_RELEASE_EOF'
NAME="SoloLinux"
PRETTY_NAME="SoloLinux"
ID=sololinux
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="0;38;2;37;104;151"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo
OS_RELEASE_EOF

ln -sf /etc/os-release /usr/lib/os-release

# Install bootloader
if [[ "\$BOOTMODE" == "UEFI" ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
    grub-install --target=i386-pc "\$DISK"
fi

# Customize GRUB
if [ -f /etc/grub.d/10_linux ]; then
    sed -i 's/Arch Linux/SoloLinux/g' /etc/grub.d/10_linux
    sed -i 's/Arch/SoloLinux/g' /etc/grub.d/10_linux
fi
if [ -f /etc/grub.d/30_os-prober ]; then
    sed -i 's/Arch Linux/SoloLinux/g' /etc/grub.d/30_os-prober
fi

echo 'GRUB_DISTRIBUTOR="SoloLinux"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

CHROOT_EOF

print_success "System configuration complete"

### ==========================================
### CLEANUP
### ==========================================
print_step "Unmounting filesystems..."

umount -R /mnt
swapoff "$PSWAP"
if [[ "$ENCRYPT" == "y" ]]; then
    cryptsetup close soloroot
fi

### ==========================================
### SUCCESS MESSAGE
### ==========================================
clear
print_header

echo -e "${GREEN}${SL_BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║              Installation Completed Successfully!                 ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${SL_RESET}"

print_section "Installation Details"
echo ""
echo -e "  ${SL_COLOR}System:${SL_RESET}     SoloLinux"
echo -e "  ${SL_COLOR}Disk:${SL_RESET}       $DISK"
echo -e "  ${SL_COLOR}Hostname:${SL_RESET}   $HOSTNAME"
echo -e "  ${SL_COLOR}Username:${SL_RESET}   $USERNAME"
echo -e "  ${SL_COLOR}Sudo:${SL_RESET}       $([ "$SUDOOPT" == "y" ] && echo "${GREEN}Enabled${SL_RESET}" || echo "${YELLOW}Disabled${SL_RESET}")"
echo -e "  ${SL_COLOR}Encrypted:${SL_RESET}  $([ "$ENCRYPT" == "y" ] && echo "${GREEN}Yes${SL_RESET}" || echo "${YELLOW}No${SL_RESET}")"
echo ""

print_section "Next Steps"
echo ""
print_info "1. Reboot into your new system:"
echo -e "     ${CYAN}reboot${SL_RESET}"
echo ""
print_info "2. After login, setup the desktop environment:"
echo -e "     ${CYAN}bash solo_gui_setup.sh${SL_RESET}"
echo ""
print_info "3. Use the SoloLinux package manager:"
echo -e "     ${CYAN}sudo slpm help${SL_RESET}"
echo ""

echo -e "${SL_COLOR}${SL_BOLD}═══════════════════════════════════════════════════════════════════${SL_RESET}"
echo ""
