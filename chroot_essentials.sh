# arch-chroot essential configuration script
#!/bin/bash

# activate parallel downloads
echo -ne "\n[options]\nParallelDownloads = 5\nVerbosePkgLists\nColor\n" >> /etc/pacman.conf

# refresh archlinux-keyring (sometimes run into issues)
pacman -Sy --noconfirm --quiet --needed archlinux-keyring
pacman-key --populate archlinux


# essential packages
pacman -S --noconfirm --quiet --needed vim efibootmgr grub networkmanager intel-ucode openssh man-db man-pages texinfo git

# time configs
ln -sf /usr/share/Asia/Jakarta /etc/localtime
hwclock --systohc

# localization
mv /etc/locale.gen /etc/locale.gen.old
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# hostname configs
echo -ne "Hostname for this machine: "
read hostn
echo $hostn > /etc/hostname

echo -e "Insert password for $hostn root user: "
passwd

# configure grub bootloader, ssh and network manager
mnt_tgt=`findmnt -n -t vfat -o TARGET 2>&1`

grub-install --target=x86_64-efi --efi-directory=$mnt_tgt --bootloader-id=GRUB
grub-mkconfig -o "$mnt_tgt/grub/grub.cfg"

echo -ne "\nPasswordAuthentication yes\n" >> /etc/ssh/sshd_config

systemctl enable NetworkManager
systemctl enable sshd

# [optional] non-root user creation
read -p "Create non-root user? [n/Y]: " isCreate

if [ "$isCreate" = "n" -o "$isCreate" = "N" ]; then
  exit 0
elif [ "$isCreate" != "y" -a "$isCreate" != "Y" -a "$isCreate" != "" ]; then
  echo "invalid input!"
  exit 1
else
  read -p "Non-root username: " username
  useradd -mG wheel $username
  passwd $username
  echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/permit_wheelgroup
fi

read -p "Install further packages (DE, Browser, Essential fonts, etc...)? [n/Y]" isMoreInstall

if [ "$isMoreInstall" = "n" -o "$isMoreInstall" = "N" ]; then
  exit 0
elif [ "$isMoreInstall" != "y" -a "$isMoreInstall" != "Y" -a "$isMoreInstall" != "" ]; then
  echo "invalid input!"
  exit 1
else
  echo -e "\n1. I already have a textfile contains list of packages needed"
  echo -e "2. I need to input packages manually\n"

  read -p "Select options: " optPackages
  if [ $optPackages -eq 1 ]; then
    read -p "locate textfile: " textdir
    xargs pacman -S --noconfirm --quiet < $textdir
  elif [ $optPackages -eq 2 ]; then
    read -p "list package names: " packages
    pacman -S --noconfirm --quiet $packages
  else
    echo "Invalid selection"
  fi
fi