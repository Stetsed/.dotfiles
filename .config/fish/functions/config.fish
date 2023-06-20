function config --wraps='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME' --description 'alias config=lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    if count $argv >/dev/null
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1
            git $argv
        else
            yadm $argv
        end
    else
        lazygit --git-dir=$HOME/.local/share/yadm/repo.git/ --work-tree=$HOME
    end
end
