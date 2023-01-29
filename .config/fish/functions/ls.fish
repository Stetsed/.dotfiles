function ls --wraps='exa -lhg' --description 'alias ls=exa -lhg'
  exa -lhg $argv; 
end
