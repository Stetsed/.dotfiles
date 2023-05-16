function cliphistory --wraps='cliphist list | fzf | cliphist decode | wl-copy' --description 'alias cliphistory=cliphist list | fzf | cliphist decode | wl-copy'
    cliphist list | fzf | cliphist decode | wl-copy $argv
end
