if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

set fish_greeting ""
set QT_QPA_PLATFORM wayland
set MOZ_ENABLE_WAYLAND 1
set EDITOR nvim
set LIBVIRT_DEFAULT_URI "qemu:///system"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
set BAT_THEME Catppuccin-mocha
set fzf_dir_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
set PATH $PATH ~/.cargo/bin
