# Ifumikuah's Arch Linux setup for daily drive (KDE on Wayland)
#!/bin/bash

# THIS SCRIPT MUST RUN AS ROOT
if [ $(id -u) -ne 0 ]; then 
  echo Please run this script as root or using sudo!
  exit
fi

read -p "Current non-root username: " nonroot
if [ nonroot = "" ]; then
  echo "Invalid username"
  exit 1
fi

echo "Checking for mandatory textfile presence (packages for desktop environment)..."
if [ ! -r "detrux_de_essentials.txt" ]; then
  echo "\"detrux_de_essentials\" textfile doesn't exist!"
  exit 1
fi

xargs pacman -S --noconfirm --quiet --needed < detrux_de_essentials.txt
pacman -S --noconfirm --quiet --needed pipewire pipewire-alsa pipewire-pulse wireplumber calf lsp-plugins easyeffects git reflector intel-media-driver
reflector --latest 5 --sort score --ipv4 --save /etc/pacman.d/mirrorlist

if [ ! -d /etc/sddm.conf.d ]; then
  mkdir -p /etc/sddm.conf.d
fi
echo "GreeterEnvironment=QT_SCREEN_SCALE_FACTORS=1.25,QT_FONT_DPI=192" > /etc/sddm.conf.d/hidpi.conf

if [ ! -d /home/$nonroot/.config/environment.d ]; then
  su - $nonroot -c "mkdir -p /home/$nonroot/.config/environment.d"
fi
su - $nonroot -c "echo "ELECTRON_OZONE_PLATFORM_HINT=wayland" > /home/$nonroot/.config/environment.d/electron_force_wayland.conf"

passwd --delete $nonroot
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/temp_authorize_nopaswd

su - $nonroot -c "git clone https://aur.archlinux.org/yay.git && cd yay && makepkg --noconfirm -si"
rm -rf /home/$nonroot/yay

rm /etc/sudoers.d/temp_authorize_nopaswd
echo "Password for username $nonroot"
passwd $nonroot

systemctl enable sddm
reboot

# echo "Setting up ssh and git credentials for git ssh..."

# pacman -S --noconfirm --quiet kwallet kwalletmanager ksshaskpass wl-clipboard

# su - nonroot -c "echo "SSH_ASKPASS=/usr/bin/ksshaskpass" >> .config/environment.d/user_env.conf"
# su - nonroot -c "echo "SSH_ASKPASS_REQUIRE=prefer" >> .config/environment.d/user_env.conf"

# su - nonroot -c "ssh-keygen -t rsa -b 4096 -C "$nonroot""
# su - nonroot -c "eval "$(ssh-agent -s)""
# su - nonroot -c "ssh-add ~/.ssh/id_rsa"

# cat ~/.ssh/id_rsa.pub | wl-copy
# echo "Public RSA key has been copied to buffer, check your clipboard manager and add it to github"

