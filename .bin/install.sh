#!/bin/bash

install_yay() {
  sudo pacman -Syu git

  git clone https://aur.archlinux.org/yay-bin.git

  cd yay-bin

  makepkg -si
}

install_package() {
  # Install the package
  yay -Syu bluedevil bluez-utils brightnessctl grimblast-git neovim network-manager-applet rofi-lbonn-wayland-git starship thunar thunar-archive-plugin thunar-volman vscodium-bin webcord-bin wl-clipboard librewolf-bin chatgpt-desktop-bin ttf-nerd-fonts-symbols-2048-em ttf-nerd-fonts-symbols-common neofetch swaybg waybar-hyprland-git
}

install_repository(){
  git clone --bare git@github.com:Stetsed/.dotfiles.git $HOME/.dotfiles
  function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
  }
  mkdir -p ~/.config-backup
  config checkout
  if [ $? = 0 ]; then
    echo "Checked out config.";
    else
      echo "Backing up pre-existing dot files.";
      config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
  fi;
  config checkout
  config config status.showUntrackedFiles no
}

install_yay && install_package && install_repository

