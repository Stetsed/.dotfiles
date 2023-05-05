function nano --description 'Edit File with sudo if needed'
    set file $argv[1]
    if test ! -e $file
        echo "$file does not exist"
    else if test -w $file
        kitten edit-in-kitty $argv
    else
        sudo kitten edit-in-kitty $argv
    end
end
