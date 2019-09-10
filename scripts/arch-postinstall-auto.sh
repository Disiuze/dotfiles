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
		echo "Changing ${UNAME}'s shell to sh..."
		usermod -s /bin/zsh $UNAME
		;;
	fish)
		pacman -S fish --noconfirm
		echo "Changing ${UNAME}'s shell to fish..."
		usermod -s /bin/sh $UNAME
		;;
esac

pacman -S xf86-video-vesa mesa --noconfirm
echo "What GPU driver should be used?"
echo "[ AMD / ATI / Intel / nouveau / NVidia ]"
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
esac

echo "Installing Xorg group..."
pacman -s xorg --noconfirm

echo "What DE do you want to use?"
echo "[ Deepin / KDE / MATE / Xfce ]"
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
esac

if [ ! $UDESK = 'Deepin' ]; then
	echo "Installing and enabling SDDM..."
	pacman -s sddm --noconfirm
	systemctl enable sddm
fi

echo "Install sakura? [y/n]"
read saku

if [ $saku = 'y' ]; then
	pacman -S sakura --noconfirm
fi

echo "su'ing into ${UNAME}, installing yay..."
su $UNAME sh <<"EOT"
cd /home/$UNAME/
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
exit 0
EOT

echo "Finishing touches..."
echo 'set linenumbers' >> /home/$UNAME/.nanorc
echo 'set softwrap' >> /home/$UNAME/.nanorc
if [ $saku = 'y' ]; then
	wget 'https://raw.githubusercontent.com/Disiuze/dotfiles/master/.config/sakura/sakura.conf' -O '/home/$UNAME/.config/sakura/sakura.conf'

echo "Post-Install complete!"
echo "Reboot ASAP to ensure the system still works."
