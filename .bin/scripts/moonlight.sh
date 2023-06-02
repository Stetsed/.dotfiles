#!/bin/sh

handle() {
  case $1 in
    "fullscreen>>1" ) moonlight 1 ;;
    "fullscreen>>0" ) moonlight 0 ;;
  esac
}

moonlight() {
  if [[ $1 = 1 ]]; then
    app=$(hyprctl activewindow -j)

    title=$(echo $app | jq -r '.title')
    if [[ "$title" = "Moonlight" ]]; then
      fullscreen=$(echo $app | jq -r '.fullscreen')
      if [[ $fullscreen = "true" ]]; then
        hyprctl dispatch submap moonlight
      fi
    fi
  elif [[ $1 = 0 ]]; then
    hyprctl dispatch submap reset
  else
    echo "bruh"
  fi
}


socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
