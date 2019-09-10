#!/bin/sh

echo "-----Disiuze's Post-Install Script-----"
echo "Ensure you have a working internet connection."
echo "This script creates a new user, changes the default CLI editor to nano, installs a shell, a DE, and finally yay."

echo "Name the first user: "
read UNAME

echo "Installing wget and git, just to be safe."
pacman -S wget git --noconfirm

useradd -m -G wheel $UNAME
echo $UNAME:$UNAME | chpasswd

echo 'VISUAL=nano' >> /etc/environment
echo 'EDITOR=nano' >> /etc/environment

echo "${UNAME}'s password has been set to ${UNAME}. Change this later."

echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
echo "Added wheel group to sudoers, ${UNAME} can use sudo."

echo "Which shell do you want to use?"
echo "[sh / bash / dash / zsh / fish]"
read USHELL

case $USHELL in
	sh)
		echo "Changing ${UNAME}'s shell to sh..."
		usermod -s /bin/sh $UNAME
		;;
	bash)
		echo "Changing ${UNAME}'s shell to bash..."
		usermod -s /bin/bash $UNAME
		;;
	dash)
		pacman -S dash --noconfirm
		echo "Changing ${UNAME}'s shell to dash..."
		usermod -s /bin/dash $UNAME
		;;
	zsh)
		pacman -S zsh --noconfirm
		echo "Changing ${UNAME}'s shell to zsh..."
		usermod -s /bin/zsh $UNAME
		;;
	fish)
		pacman -S fish --noconfirm
		echo "Changing ${UNAME}'s shell to fish..."
		usermod -s /bin/fish $UNAME
		;;
esac

pacman -S xf86-video-vesa mesa --noconfirm
echo "What GPU driver should be used?"
echo "[ AMD / ATI / Intel / nouveau / NVidia / skip ]"
read GPUDRIVER

case $GPUDRIVER in
	AMD)
		pacman -S xf86-video-amdgpu --noconfirm
		;;
	ATI)
		pacman -S xf86-video-ati --noconfirm
		;;
	Intel)
		pacman -S xf86-video-intel --noconfirm
		;;
	nouveau)
		pacman -S xf86-video-nouveau --noconfirm
		;;
	NVidia)
		pacman -S nvidia nvidia-utils --noconfirm
		echo "NOTE! If your machine has Optimus, it needs to set up manually! Check the Arch Wiki!"
		;;
	skip)
		echo "Skipping driver install."
		;;
esac

echo "Installing Xorg group..."
pacman -S xorg --noconfirm

echo "What DE/WM do you want to use?"
echo "[ Deepin / KDE / MATE / Xfce / i3 ]"
read UDESK

case $UDESK in
	Deepin)
		pacman -S deepin deepin-extra networkmanager lightdm --noconfirm
		echo 'greeter-session=lightdm-deepin-greeter' >> /etc/lightdm/lightdm.conf
		systemctl enable lightdm
		;;
	KDE)
		pacman -S plasma --noconfirm
		;;
	MATE)
		pacman -S mate --noconfirm
		;;
	Xfce)
		pacman -S xfce4 --noconfirm
		;;
	i3)
		pacman -S i3-gaps dmenu --noconfirm
		;;
esac

if [ ! $UDESK = 'Deepin' ]; then
	echo "Installing and enabling SDDM..."
	pacman -S sddm --noconfirm
	systemctl enable sddm
fi

echo "Install sakura? [y/n]"
read saku

if [ $saku = 'y' ]; then
	pacman -S sakura --noconfirm
fi

echo "Creating yay installation script..."
echo 'git clone https://aur.archlinux.org/yay.git' >> /home/$UNAME/yay-inst.sh
echo 'cd yay' >> /home/$UNAME/yay-inst.sh
echo 'makepkg -si' >> /home/$UNAME/yay-inst.sh
chmod +rx /home/$UNAME/yay-inst.sh

echo "Run 'yay-inst.sh' as ${UNAME} to install yay."
# I'm not even saving time with this anymore
# I don't know what's driving me to put everything in scripts

echo "Finishing touches..."
echo 'set linenumbers' >> /home/$UNAME/.nanorc
echo 'set softwrap' >> /home/$UNAME/.nanorc
if [ $saku = 'y' ]; then
	wget 'https://raw.githubusercontent.com/Disiuze/dotfiles/master/.config/sakura/sakura.conf' -O '/home/$UNAME/.config/sakura/sakura.conf'

chown -R $UNAME:wheel /home/$UNAME

echo "Post-Install complete!"
echo "Reboot ASAP to ensure the system still works."
