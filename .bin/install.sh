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
  yay -Syu --noconfirm gdm dunst bluedevil bluez-utils brightnessctl grimblast-git neovim network-manager-applet rofi-lbonn-wayland-git starship thunar thunar-archive-plugin thunar-volman vscodium-bin webcord-bin wl-clipboard librewolf-bin chatgpt-desktop-bin ttf-nerd-fonts-symbols-2048-em ttf-nerd-fonts-symbols-common neofetch swaybg waybar-hyprland-git nfs-utils btop tldr swaylock-effects obsidian fish
}

install_dotfiles(){
  git clone --bare https://github.com/Stetsed/.dotfiles.git $HOME/.dotfiles
  function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
  }
  config checkout -f 
  config config status.showUntrackedFiles no
  config remote set-url origin git@github.com:Stetsed/.dotfiles.git
}

extra_configuration() {
  echo "192.168.1.190:/mnt/Vault/Storage /mnt/data nfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
  sudo mount -t nfs 192.168.1.190:/mnt/Vault/Storage /mnt/data
  sudo systemctl enable --now bluetooth
  sudo systemctl enable gdm

  ln -s /mnt/data/Stetsed/Storage ~/Storage
  ln -s /mnt/data/Stetsed/Documents ~/Documents
}


# Install Gum to allow nice UI
sudo pacman -Syu --noconfirm gum

clear

echo "What parts of my dotfiles would you like to install, be warned to install packages yay needs to be selected aswell. And the Extra Configuration files are just personal so you probally just want Yay, Packages and dotfiles"

YAY="Yay"; PACKAGES="Packages"; DOTFILES="Dotfiles"; EXTRA="Extra Personal Configuration"
INSTALL=$(gum choose --cursor-prefix "[ ] " --selected-prefix "[✓] " --no-limit "$YAY" "$PACKAGES" "$DOTFILES" "$EXTRA" )

grep -q "$YAY" <<< "$INSTALL" && install_yay
grep -q "$PACKAGES" <<< "$INSTALL" && install_package
grep -q "$DOTFILES" <<< "$INSTALL" && install_dotfiles
grep -q "$EXTRA" <<< "$INSTALL" && extra_configuration
