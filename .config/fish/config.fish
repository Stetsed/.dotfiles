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
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
set BAT_THEME Catppuccin-mocha
set fzf_dir_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
set PATH $PATH ~/.cargo/bin
