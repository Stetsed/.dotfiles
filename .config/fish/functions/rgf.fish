function rgf --wraps='rg --files | rg ' --description 'alias rgf=rg --files | rg '
  rg --files | rg  $argv
        
end
