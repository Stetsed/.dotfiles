if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    keychain --eval ~/.ssh/*.key | source
end

set -x fish_greeting ""
set -x EDITOR nvim
set -x LIBVIRT_DEFAULT_URI "qemu:///system"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -x MANROFFOPT -c
set -x BAT_THEME Catppuccin-mocha
set -x PATH $PATH ~/.cargo/bin
set -x GPG_TTY $(tty)
set -x HASTEBIN_URL https://paste.selfhostable.net

if [ -f ~/.env ]
    export (cat ~/.env |xargs -L 1)
end

if [ (tty) = /dev/tty1 ]
    Hyprland >/dev/null 2>&1
end
