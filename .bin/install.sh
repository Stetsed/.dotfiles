#!/bin/bash

# curl -Lks https://raw.githubusercontent.com/Stetsed/.dotfiles/main/.bin/install.sh | /bin/bash

install_yay() {
  sudo pacman -Syu git

  git clone https://aur.archlinux.org/yay-bin.git

  cd yay-bin

  makepkg -s

  sudo pacman -U yay-bin*

  cd ..

  rm -rf yay-bin
}

install_package() {
  # Install the package
  yay -Syu --noconfirm gdm dunst bluedevil bluez-utils brightnessctl grimblast-git neovim network-manager-applet rofi-lbonn-wayland-git starship thunar thunar-archive-plugin thunar-volman vscodium-bin webcord-bin wl-clipboard librewolf-bin chatgpt-desktop-bin ttf-nerd-fonts-symbols-2048-em ttf-nerd-fonts-symbols-common neofetch swaybg waybar-hyprland-git nfs-utils btop tldr swaylock-effects obsidian
}

install_repository(){
  git clone --bare https://github.com/Stetsed/.dotfiles.git $HOME/.dotfiles
  function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
  }
  config checkout -f 
  config config status.showUntrackedFiles no
  config remote set-url origin git@github.com:Stetsed/.dotfiles.git
}

extra_configuration() {
  echo "192.168.1.11:/mnt/vault/data /mnt/data nfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
  sudo mount -t nfs 192.168.1.11:/mnt/vault/data /mnt/data nfs defaults,_netdev 0 0
  sudo systemctl enable --now bluetooth
  sudo systemctl enable gdm
}

symlinks_configuration(){
  ln -s /mnt/data/Storage ~/Storage
  ln -s /mnt/data/Documents ~/Documents
}

install_yay && install_package && install_repository

if [[ $@ == *"--extra"* ]]; then
  extra_configuration
else
  echo "--extra not passed"
fi

if [[ $@ == *"--symlinks"* ]]; then
  symlinks_configuration
else
  echo "--symlinks not passed"
fi
