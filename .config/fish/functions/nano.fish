function nano --description 'Edit File with sudo if needed'
    set file $argv[1]
    if test ! -f $file
        if test -w $file
            touch $file
            if set -q SSH_CLIENT || set -q SSH_TTY
                kitten edit-in-kitty $argv
            else
                nvim $argv
            end
        else
            sudo touch $file
            if set -q SSH_CLIENT || set -q SSH_TTY
                sudo kitten edit-in-kitty $argv
            else
                sudo nvim $argv
            end
        end
    else if test -w $file
        if set -q SSH_CLIENT || set -q SSH_TTY
            kitten edit-in-kitty $argv
        else
            nvim $argv
        end
    else
        if set -q SSH_CLIENT || set -q SSH_TTY
            sudo kitten edit-in-kitty $argv
        else
            sudo nvim $argv
        end
    end
end
