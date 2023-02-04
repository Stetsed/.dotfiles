#!/bin/bash

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
  # yay -Syu --noconfirm bluedevil bluez-utils brightnessctl grimblast-git neovim network-manager-applet rofi-lbonn-wayland-git starship thunar thunar-archive-plugin thunar-volman vscodium-bin webcord-bin wl-clipboard librewolf-bin chatgpt-desktop-bin ttf-nerd-fonts-symbols-2048-em ttf-nerd-fonts-symbols-common neofetch swaybg waybar-hyprland-git
}

install_repository(){
  git clone --bare https://github.com/Stetsed/.dotfiles.git $HOME/.dotfiles
  function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
  }
  config checkout -f 
  config config status.showUntrackedFiles no
}

install_yay && install_package && install_repository

