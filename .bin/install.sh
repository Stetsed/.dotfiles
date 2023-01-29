#!/bin/bash

install_yay() {
  sudo pacman -Syu git

  git clone https://aur.archlinux.org/yay-bin.git

  cd yay-bin

  makepkg -si
}

install_package() {
  # Install the package
  yay -Syu bluedevil bluez-utils brightnessctl grimblast-git neovim network-manager-applet rofi-lbonn-wayland-git sddm starship thunar-thunar-archive-plugin thunar-volman vscodium-bin webcord-bin wl-clipboard librewolf-bin
}

install_yay && install_package

