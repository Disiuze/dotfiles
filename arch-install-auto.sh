#!/bin/sh

echo "-----Disiuze's Arch install script v1-----"
echo "Ensure you have a working internet connection."
echo "This script overwrites all data on the selected disk."

echo "Name the system: "
read HOSTNAME

# Test UEFI BIOS
EFIVARS="$(ls /sys/firmware/efi/efivars)"
if [ -z "${EFIVARS}" ]; then
	echo "UEFI mode not enabled, aborting."
	exit 0
fi
echo "UEFI mode enabled."

timedatectl set-ntp true

# Get block device name
lsblk
echo "Input block device name: "
read BLOCKDEV
echo "Define swap partition size (MiB): "
read SWAPSIZE

echo "Creating partitions..."
parted -s "/dev/${BLOCKDEV}" mklabel gpt mkpart primary fat32 1MiB 513MiB set 1 esp on mkpart linux-swap 513MiB "${SWAPSIZE}MiB" mkpart ext4 "${SWAPSIZE}MiB" 100%

echo "Formatting partitions..."
mkfs.vfat -F32 "/dev/${BLOCKDEV}1"
mkswap "/dev/${BLOCKDEV}2"
swapon "/dev/${BLOCKDEV}2"
mkfs.ext4 "/dev/${BLOCKDEV}3"

echo "Mounting partitions..."
mount "/dev/${BLOCKDEV}3" /mnt
mkdir /mnt/boot
mount "/dev/${BLOCKDEV}1" /mnt/boot

echo "Installing packages..."
pacstrap /mnt base base-devel dialog efibootmgr

echo "Generating fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "Chrooting!"
arch-chroot /mnt /bin/bash <<"EOT"
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
echo "Local time set to Amsterdam."
hwclock --systohc
echo "en_US.UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "$(cat /etc/hostname)$HOSTNAME" > /etc/hostname
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1	localhost" >> /etc/hosts
echo "127.0.1.1	$HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts
echo "Changing root password..."
passwd

echo "Detecting CPU Vendor..."
if [ "$(lscpu)" =~ "Intel" ]; then
	echo "Intel CPU detected."
	pacman -S intel-microcode --noconfirm
	MICROINITRD='initrd=/intel-ucode.img'
fi
if [ "$(lscpu)" =~ "AMD" ]; then
	echo "AMD CPU detected."
	pacman -S amd-microcode --noconfirm
	MICROINITRD='initrd=/amd-ucode.img'
fi

ROOTUUID=$(blkid -o value -s UUID "/dev/${BLOCKDEV})

echo "Adding boot entry..."
efibootmgr --disk "/dev/${BLOCKDEV}" --part 1 --create --label "Arch Linux" --loader /vmlinuz-linux --unicode "root=PARTUUID=${ROOTUUID} rw ${MICROINITRD} initrd=\initramfs-linux.img" --verbose
EOT
echo "Install complete, enable and/or disable network profiles as necessary."
echo "Consider running the post-install script after rebooting."
exit 0
