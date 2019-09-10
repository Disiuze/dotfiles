#!/bin/sh

echo "-----Disiuze's Arch install script v1-----"
echo "Ensure you have a working internet connection."
echo "This script overwrites all data on the selected disk."

echo "Name the system: "
read HOSTUNAME

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
echo "Enable microcode updates? [y/n]"
read microask

let SWAPSIZE=513+$SWAPSIZE

echo "Creating partitions..."
parted -s "/dev/${BLOCKDEV}" mklabel gpt
parted -s "/dev/${BLOCKDEV}" mkpart primary fat32 1MiB 513MiB
parted -s "/dev/${BLOCKDEV}" set 1 esp on
parted -s "/dev/${BLOCKDEV}" mkpart linux-swap 513MiB "${SWAPSIZE}MiB"
parted -s "/dev/${BLOCKDEV}" mkpart ext4 "${SWAPSIZE}MiB" 100%

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
pacstrap /mnt base base-devel dialog efibootmgr wpa_supplicant git wget

echo "Generating fstab file..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "$BLOCKDEV" > /mnt/root/blockdev.tmp
echo "$microask" > /mnt/root/microask.tmp

echo "Chrooting!"
arch-chroot /mnt /bin/bash <<"EOT"
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
echo "Local time set to Amsterdam."
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$HOSTUNAME" > /etc/hostname
echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1	localhost" >> /etc/hosts
echo "127.0.1.1	$HOSTUNAME.localdomain $HOSTUNAME" >> /etc/hosts
echo "Setting root password to root."
echo root:root | chpasswd

BLOCKDEV=$(cat /root/blockdev.tmp)
microask=$(cat /root/microask.tmp)

if [ "$microask" = 'y' ]; then
echo "Detecting CPU Vendor..."
	if [[ "$(lscpu)" =~ "Intel" ]]; then
		echo "Intel CPU detected."
		pacman -S intel-ucode --noconfirm
		MICROINITRD='intel-ucode.img'
	fi
	if [[ "$(lscpu)" =~ "AMD" ]]; then
		echo "AMD CPU detected."
		pacman -S amd-ucode --noconfirm
		MICROINITRD='amd-ucode.img'
	fi
fi

ROOTUUID=$(blkid -o value -s PARTUUID "/dev/${BLOCKDEV}3")

echo "Adding boot entry..."
if [ "$microask" = 'y' ]; then
	echo "efibootmgr --disk "/dev/${BLOCKDEV}" --part 1 --create --label 'Arch Linux' --loader /vmlinuz-linux --unicode 'root=PARTUUID='"${ROOTUUID}"' rw initrd=\'"${MICROINITRD}"' initrd=\initramfs-linux.img' --verbose" | bash
	echo "efibootmgr --disk "/dev/${BLOCKDEV}" --part 1 --create --label 'Arch Linux' --loader /vmlinuz-linux --unicode 'root=PARTUUID='"${ROOTUUID}"' rw initrd=\'"${MICROINITRD}"' initrd=\initramfs-linux.img' --verbose" > /root/efi-boot-vars
else
	echo "efibootmgr --disk "/dev/${BLOCKDEV}" --part 1 --create --label 'Arch Linux' --loader /vmlinuz-linux --unicode 'root=PARTUUID='"${ROOTUUID}"' rw initrd=\initramfs-linux.img' --verbose" | bash
	echo "efibootmgr --disk "/dev/${BLOCKDEV}" --part 1 --create --label 'Arch Linux' --loader /vmlinuz-linux --unicode 'root=PARTUUID='"${ROOTUUID}"' rw initrd=\initramfs-linux.img' --verbose" > /root/efi-boot-vars
fi
echo "Install complete, enable and/or disable network profiles as necessary."
echo "Consider running the post-install script after rebooting."
echo "NOTE: root password is 'root'!"
rm /root/blockdev.tmp
rm /root/microask.tmp
exit 0
EOT
echo "Don't forget to unmount all partitions."

echo "Download post-install script? [y/n]"
read postinst
if [ $postinst = 'y' ]; then
	wget 'https://raw.githubusercontent.com/Disiuze/dotfiles/master/scripts/arch-postinstall-auto.sh' -O /mnt/root/arch-postinstall-auto.sh
fi
