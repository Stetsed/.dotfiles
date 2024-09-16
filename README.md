[![Last Commit](https://img.shields.io/github/last-commit/stetsed/.dotfiles)](https://github.com/Stetsed/.dotfiles/commits/main)

# Stetsed's Dotfiles

Welcome to my Dotfiles repository which I use for my linux desktop. I hope this helps you to find what your looking for and be able to improve your own Linux Desktop. My setup basically always uses the Catppuccin Mocha Color scheme so you will find alot of that.

## Programs

- Theme: [Catppuccin Mocha](https://github.com/catppuccin/catppuccin)
- Window Manager: [Hyprland](https://github.com/hyprwm/Hyprland)
- Terminal: [Kitty](https://github.com/kovidgoyal/kitty)
- Shell: [Fish](https://github.com/fish-shell/fish-shell)
- Panel: [Waybar](https://aur.archlinux.org/packages/waybar-hyprland-git)
- Application Launcher: [Rofi](https://github.com/davatorium/rofi)
- Nvim Configuration: [LazyVim](https://github.com/LazyVim/LazyVim)
- Browser: [LibreWolf](https://librewolf.net/) + [Catppuccin Mocha Saphire](https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_sapphire.xpi)
- Discord: [WebCord](https://github.com/SpacingBat3/WebCord) + [Catppuccin Mocha](https://github.com/catppuccin/discord)
- Note Taking App: [Obsidian](https://obsidian.md/) + [Catppuccin Mocha](https://github.com/catppuccin/obsidian)

## Modifications that need to be made to use Dotfiles

- For Paru I use a custom pacman.conf which is hardcoded to my user directory, change this in ~/.config/paru/paru.conf
- Other changes which I might not have noted here, please don't just copy some random persons dotfiles and expect them to work.

### [Packages](https://github.com/Stetsed/.dotfiles/blob/main/.packages.list)

## Install Script

Run the below command inside of an archlinux ISO to setup a ZFS system, and enter Stetsed/.dotfiles at the repository stage to use my dotfiles

```bash
bash -c "$(curl -Ls selfhostable.net/install)"
```

## Acknowledgements

- [Dotfiles](https://github.com/linuxmobile/hyprland-dots) Dotfiles which I heavily used to inspire my creation, thanks for the examples :D.

## Screenshots

<details>
  <summary>Configuration with Waybar System bar</summary>

  ![.bin/show/waybar/screenshot.png](.bin/show/waybar/screenshot.png)
</details>

<details>
  <summary>Eww deprecated as of 2024-09-15</summary>
<details>
  <summary>Configuration with Eww System bar</summary>

  ![.bin/show/eww-bar/screenshot.png](.bin/show/eww-bar/screenshot.png)

</details>

<details open>
  <summary>Rest of my Configuration</summary>

  ![.bin/show/extra/firefox.png](.bin/show/extra/firefox.png)

  ![.bin/show/extra/discord.png](.bin/show/extra/discord.png)

  ![.bin/show/extra/obsidian.png](.bin/show/extra/obsidian.png)
</details>
</details>
