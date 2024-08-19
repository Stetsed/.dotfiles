function ssh --description 'alias ssh=kitty +kitten ssh'
    if test -n $KITTY_PID
        set TERM xterm
        kitty +kitten ssh $argv
    else
        set TERM xterm
        /bin/ssh $argv
    end
end
