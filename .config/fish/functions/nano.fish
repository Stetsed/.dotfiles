function nano --description 'Edit File with sudo if needed'
    set file $argv[1]
    if test ! -e $file
        echo "File $file does not exist"
        return 1
    end
    if test -w $file
        kitten edit-in-kitty $argv
    else
        sudo kitten edit-in-kitty $argv
    end
end
