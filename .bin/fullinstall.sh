#!/bin/bash

ZFS_Run ()
{
  clear
  ZFS_Select_Drive

  clear
  ZFS_Get_ZFS

  clear
  ZFS_Partition_Drive

  clear
  ZFS_Setup_Filesystem

  clear
  ZFS_Setup_Basesystem
}

ZFS_Select_Drive ()
{
  echo "Choose the drive you want to install on."
  DRIVES=$(ls -1 /dev/disk/by-id/nvme-* | awk -F '/' '{printf "%s ", $NF}')
  SELECTED_DRIVE=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓]" $DRIVES)

  return
}

ZFS_Get_ZFS ()
{
  echo "Installing the ArchISO ZFS Package"
  curl -s https://raw.githubusercontent.com/eoli3n/archiso-zfs/master/init | bash

  return 
}

ZFS_Partition_Drive ()
{
  sgdisk -n1:0:+550M -t1:ef00 /dev/disk/by-id/$SELECTED_DRIVE
  sgdisk -n2:0:0 -t2:bf00 /dev/disk/by-id/$SELECTED_DRIVE

  sleep 10

  mkfs.vfat /dev/disk/by-id/$SELECTED_DRIVE-part1

  return

}

ZFS_Setup_Filesystem ()
{
  zpool labelclear /dev/disk/by-id/$SELECTED_DRIVE
  sleep 10 

  zpool create -f -O canmount=off -o ashift=12 zroot /dev/disk/by-id/$SELECTED_DRIVE-part2
  zfs create -o canmount=off -o mountpoint=none zroot/ROOT
  zfs create -o canmount=noauto -o mountpoint=/ zroot/ROOT/default
  zfs set compression=on zroot
  zfs set atime=off zroot
  zfs set xattr=sa zroot
  zfs set acltype=posixacl zroot

  zfs create -o mountpoint=none zroot/data
  zfs create -o mountpoint=/home zroot/data/home

  zfs umount -a 
  zpool export zroot

  zpool import -d /dev/disk/by-id -R /mnt zroot

  zfs mount zroot/ROOT/default
  zpool set bootfs=zroot/ROOT/default zroot

  mkdir /mnt/boot 
  mount /dev/disk/by-id/$SELECTED_DRIVE-part1 /mnt/boot
  mkdir /mnt/etc

  return
}

ZFS_Setup_Basesystem ()
{
  genfstab -U /mnt >> /mnt/etc/fstab

  pacstrap /mnt base base-devel linux linux-firmware neovim networkmanager intel-ucode

  arch-chroot /mnt

  umount -R /mnt

  zfs umount -a

  zpool export zroot

  reboot
}

Chroot_Run ()
{
  clear
  Chroot_Setup_ZFS

  clear
  Chroot_Install_Packages

  clear
  Chroot_User

  clear
  Chroot_Final
}

Chroot_Setup_ZFS ()
{
  echo -e '[archzfs]\nServer = https://archzfs.com/$repo/$arch' >> /etc/pacman.conf
  pacman-key -r DDF7DB817396A49B2A2723F7403BD972F75D9D76
  pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76
  pacman -Syu
}

Chroot_Install_Packages ()
{
  pacman -S linux-headers zfs-dkms openssh networkmanager fish
}

Chroot_User ()
{
  useradd -m -G wheel -s /usr/bin/fish stetsed
  (echo "BlahBlah"; echo "BlahBlah") | passwd stetsed
}

Chroot_Final ()
{
  zpool set cachefile=/etc/zfs/zpool.cache zroot

  bootctl install

  systemctl enable NetworkManager

  echo -e "title Arch Linux\nlinux vmlinuz-linux\ninitrd intel-ucode.img\ninitrd initramfs-linux.img\noptions zfs=zroot/ROOT/default rw" > /boot/loader/entries/arch.conf

  echo "default arch" >> /boot/loader/loader.conf

  echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

  systemctl enable zfs.target
  systemctl enable zfs-import-cache
  systemctl enable zfs-mount
  zgenhostid $(hostid)

  echo "Remember to edit the mkinciptio.conf file and add the zfs hook after the keyboard"
}

User_Run ()
{
  clear
  User_Home

  clear
  User_Yay

  clear
  User_Packages

  clear
  User_Dotfiles

  clear
  User_Extra
}

User_Home ()
{
  sudo mkdir /home/stetsed

  sudo chown stetsed:stetsed -R /home/stetsed

  sudo chmod 700 -R /home/stetsed
  
  cd /home/stetsed
}

User_Yay ()
{
  sudo pacman -Syu git

  git clone https://aur.archlinux.org/yay-bin.git

  cd yay-bin

  makepkg -s

  sudo pacman -U yay-bin*

  cd ..

  rm -rf yay-bin
}

User_Packages ()
{
  yay -Syu pavucontrol pipewire-pulse dunst bluedevil bluez-utils brightnessctl grimblast-git neovim network-manager-applet rofi-lbonn-wayland-git starship thunar thunar-archive-plugin thunar-volman webcord-bin wl-clipboard librewolf-bin neofetch swaybg waybar-hyprland-git nfs-utils btop tldr swaylock-effects obsidian fish hyprland-git xdg-desktop-portal-wlr xdg-desktop-portal-hyprland-git exa alacritty noto-fonts-emoji qt5-wayland qt6-wayland blueman swappy playerctl wlogout sddm-git nano ttf-jetbrains-mono-nerd lazygit swayidle
}

User_Dotfiles ()
{
  git clone --bare https://github.com/Stetsed/.dotfiles.git $HOME/.dotfiles
  function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
  }
  config checkout -f 
  config config status.showUntrackedFiles no
  config remote set-url origin git@github.com:Stetsed/.dotfiles.git
}

User_Extra ()
{
  echo "192.168.1.190:/mnt/Vault/Storage /mnt/data nfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
  sudo mkdir /mnt/data
  sudo mount -t nfs 192.168.1.190:/mnt/Vault/Storage /mnt/data
  # Enable services
  sudo systemctl enable --now bluetooth
  sudo systemctl enable sddm
  systemctl --user enable --now pipewire
  systemctl --user enable --now pipewire-pulse

  # Add autologin to the sddm.conf and create the group.
  echo -e "[Autologin]\nUser=stetsed\nSession=hyprland" | sudo tee -a /etc/sddm.conf
  sudo groupadd autologin
  sudo usermod -aG autologin stetsed

  ln -s /mnt/data/Stetsed/Storage ~/Storage
  ln -s /mnt/data/Stetsed/Documents ~/Documents
  mkdir Downloads

  timedatectl set-ntp true
  timedatectl set-timezone Europe/Amsterdam

}

Main_Run ()
{
  sudo pacman -Sy gum

  clear

  echo "What part of the installation are you on"
  ZFS="ZFS"; CHROOT="Chroot"; USER="User" 
  SELECTION=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓] " "$ZFS" "$CHROOT" "$USER" )
  grep -q "$ZFS" <<< "$SELECTION" && ZFS_Run
  grep -q "$CHROOT" <<< "$SELECTION" && Chroot_Run
  grep -q "$USER" <<< "$SELECTION" && User_Run 
}

Main_Run
