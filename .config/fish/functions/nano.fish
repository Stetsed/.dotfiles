function nano --description 'Edit File with sudo if needed'
    # To anybody reading this function, I know it's fucking scuffed. Deal with it
    if test -z $argv[1]
        nvim
        return
    end

    set file $argv[1]
    set random_string (tr -dc A-Za-z0-9 </dev/urandom | head -c 13)

    if test ! -e $file
        echo "$file does not exist"
    else if test -w $file
        kitten edit-in-kitty $argv
    else
        if set -q SSH_TTY; or set -q SSH_CLIENT
            sudo kitten edit-in-kitty $argv
        else
            set tmp_dir "/tmp/$random_string"
            set basename (basename $file)
            set original_permissions (stat -c %a $file)
            set original_owner (stat -c %u:%g $file)
            mkdir -p $tmp_dir
            cp $file $tmp_dir
            kitten edit-in-kitty $tmp_dir/$basename
            if cmp -s $tmp_dir/$basename $file
                echo "No changes made to $file"
            else
                sudo cp $tmp_dir/$basename $file
                sudo chmod $original_permissions $file
                sudo chown $original_owner $file
            end
            rm -rf $tmp_dir
        end
    end
end
