function turnoff --wraps='hyprctl keyword monitor HDMI-A-1,disable' --description 'alias turnoff=hyprctl keyword monitor HDMI-A-1,disable'
  hyprctl keyword monitor HDMI-A-1,disable $argv
        
end
