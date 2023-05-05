function nano --description 'Edit File with sudo if needed'
    set file $argv[1]
    if test ! -e $file
        if test -w $file
            touch $file
            kitten edit-in-kitty $argv
        else
            sudo touch $file
            sudo kitten edit-in-kitty $argv
        end
    else if test -w $file
        kitten edit-in-kitty $argv
    else
        sudo kitten edit-in-kitty $argv
    end
end
