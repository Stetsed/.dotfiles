function upload --wraps='~/.bin/scripts/upload.sh' --description 'Upload to the Hastebin'
    if test -z "$argv"
        ~/.bin/scripts/upload.sh & notify-send Hastebin "Link copied to clipboard"
    else
        if test -f "$argv[1]"
            command ~/.bin/scripts/upload.sh $argv[1] & notify-send Hastebin "Link copied to clipboard"
        else
            echo "File not found"
        end
    end
end
