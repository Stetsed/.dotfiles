function ls --wraps='exa -lhg' --description 'alias ls=exa -lhg'
    if type -q exa
        exa -lhg --icons $argv
    else
        ls -lhg $argv
    end
end
