function lock --wraps='loginctl lock-session' --description 'alias lock=loginctl lock-session'
  loginctl lock-session $argv
        
end
