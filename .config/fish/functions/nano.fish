function nano --description 'Edit File with sudo if needed'
    set file $argv[1]
    if test (count $argv) = 0
        set file ''
    else if test ! -e $file
        return 1
    else if test -w $file
        kitten edit-in-kitty $argv
    else
        sudo kitten edit-in-kitty $argv
    end
end
