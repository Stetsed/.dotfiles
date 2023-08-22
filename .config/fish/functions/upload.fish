function upload --wraps='~/.bin/scripts/upload.sh' --description 'Upload to the Hastebin'
    set URL $(~/.bin/scripts/upload.sh $argv)
    wl-copy $URL
    notify-send "Upload Service" "URL Copied to clipboard"

end
