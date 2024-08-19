function dig --wraps=dog --description 'alias dig=dog'
    if type -q dog
        dog $argv
    else
        dig $argv
    end
end
