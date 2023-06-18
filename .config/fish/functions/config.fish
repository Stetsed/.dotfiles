function config --wraps='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME' --description 'alias config=lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    if count $argv >/dev/null
        yadm $argv
    else
        lazygit --git-dir=$HOME/.local/share/yadm/repo.git/ --work-tree=$HOME
    end
end
