#!/bin/sh

dunst_status=""

update() {
  status=$(dunstctl is-paused)
  if [ "$status" = "true" ]
  then
    dunst_status='{"name":"dunst","instance":"dunst","color":"#FF0000","markup":"none","full_text":"Notifications: OFF"}'
  else
    dunst_status='{"name":"dunst","instance":"dunst","color":"#00FF00","markup":"none","full_text":"Notifications: ON"}'
  fi
}

i3status | (read line && echo "$line" && read line && echo "$line" && read line && echo "$line" && update && while :
do
  read line
  update
  echo ",[${dunst_status},${line#,\[}" || exit 1
done)
