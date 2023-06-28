function ssh --description 'alias ssh=kitty +kitten ssh'
    if set -q $KITTY_PID
        kitty +kitten ssh $argv
    else
        command ssh $argv
    end
end
