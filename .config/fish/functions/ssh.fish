function ssh --description 'alias ssh=kitty +kitten ssh'
    if test -n $KITTY_PID
        kitty +kitten ssh $argv
    else
        /bin/ssh $argv
    end
end
