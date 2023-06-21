if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

set -x fish_greeting ""
set -x QT_QPA_PLATFORM wayland
set -x MOZ_ENABLE_WAYLAND 1
set -x EDITOR nvim
set -x LIBVIRT_DEFAULT_URI "qemu:///system"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -x BAT_THEME Catppuccin-mocha
set -x PATH $PATH ~/.cargo/bin
set -x OBSIDIAN_USE_WAYLAND 1
set -x WLR_NO_HARDWARE_CURSORS 1
set -x GPG_TTY $(tty)
export (cat ~/.env |xargs -L 1)

if [ (tty) = /dev/tty1 ]
    Hyprland >/dev/null 2>&1 &
    vlock -a
end
