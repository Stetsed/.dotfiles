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

if [ (tty) = /dev/tty1 ]
    Hyprland
    vlock -a
end
