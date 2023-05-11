function config --wraps='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME' --description 'alias config=lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    if count $argv >0
        /usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
    else
        lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME
    end
end
