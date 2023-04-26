if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

set fish_greeting ""
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export EDITOR=nvim
export LIBVIRT_DEFAULT_URI=qemu:///system
set PATH $PATH ~/.cargo/bin
