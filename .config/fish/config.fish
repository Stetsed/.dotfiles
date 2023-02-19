if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

set fish_greeting ""
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export TERM=xterm-256color
export EDITOR=nvim
