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
set -x FZF_DEFAULT_OPTS " \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
set -x BAT_THEME Catppuccin-mocha
set -x fzf_dir_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
set -x PATH $PATH ~/.cargo/bin
set -x fzf_preview_dir_cmd exa --all --color=always

if [ (tty) = /dev/tty1 ]
    Hyprland
end
