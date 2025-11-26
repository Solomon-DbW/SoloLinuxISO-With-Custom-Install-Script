#!/bin/bash
set -e

### ==========================================
### 1. USER CONFIG
### ==========================================
DISK="$1"
HOSTNAME="sololinux"
USERNAME="solo"
PASSWORD="password"    # change this
ROOT_PASSWORD="toor"   # change this

if [ -z "$DISK" ]; then
    echo "Usage: sudo $0 /dev/sdX or /dev/nvme0n1"
    exit 1
fi

echo "!!! WARNING: This will DELETE ALL DATA on $DISK !!!"
read -p "Type 'yes' to continue: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

### ==========================================
### 2. PARTITION THE DISK
### ==========================================
echo "[+] Partitioning $DISK"

command -v parted >/dev/null || { echo "parted required"; exit 1; }

parted --script "$DISK" mklabel msdos
parted --script "$DISK" mkpart primary ext4 1MiB 101MiB
parted --script "$DISK" set 1 boot on
parted --script "$DISK" mkpart primary linux-swap 101MiB 4197MiB
parted --script "$DISK" mkpart primary ext4 4197MiB 100%

# NVMe/mmc naming
if [[ "$DISK" =~ nvme|mmc ]]; then
  P1="${DISK}p1"
  P2="${DISK}p2"
  P3="${DISK}p3"
else
  P1="${DISK}1"
  P2="${DISK}2"
  P3="${DISK}3"
fi

### ==========================================
### 3. FORMAT DISK
### ==========================================
echo "[+] Formatting partitions"

mkfs.ext4 "$P1"
mkswap "$P2"
mkfs.ext4 "$P3"

### ==========================================
### 4. MOUNT
### ==========================================
echo "[+] Mounting partitions"

mount "$P3" /mnt
mkdir -p /mnt/boot
mount "$P1" /mnt/boot
swapon "$P2"

### ==========================================
### 5. INSTALL BASE SYSTEM
### ==========================================
echo "[+] Installing base Arch packages"

pacstrap /mnt base linux linux-firmware grub sudo networkmanager

### ==========================================
### 6. FSTAB
### ==========================================
echo "[+] Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

### ==========================================
### 7. CHROOT CONFIGURATION
### ==========================================
echo "[+] Entering chroot to configure SoloLinux"

arch-chroot /mnt bash -e <<EOF

### TIME & LOCALE ###
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc

sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/' /etc/locale.gen
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf

### HOSTNAME ###
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

### USERS ###
echo "root:$ROOT_PASSWORD" | chpasswd

useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

### ENABLE NETWORKING ###
systemctl enable NetworkManager

### BOOTLOADER ###
grub-install --target=i386-pc "$DISK"
grub-mkconfig -o /boot/grub/grub.cfg

### CUSTOM SOLOLINUX OS-RELEASE ###
cat <<OSR > /etc/os-release
NAME="SoloLinux"
PRETTY_NAME="SoloLinux"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="0;38;2;37;104;151"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo
OSR

EOF

### ==========================================
### 8. FINISH
### ==========================================
echo "[+] Unmounting..."
umount -R /mnt

echo "============================================"
echo "      SoloLinux Installation Complete!"
echo "============================================"
echo "User: $USERNAME"
echo "Password: $PASSWORD"
echo "Reboot now to enter SoloLinux."

