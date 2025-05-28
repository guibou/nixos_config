#!/bin/sh

dunst_status=""
tailscale_status=""
bluetooth_status=""

red=$(xrdb -get color1)
yellow=$(xrdb -get color11)
green=$(xrdb -get color10)
foreground=$(xrdb -get foreground)

update() {
  status=$(dunstctl is-paused)
  if [ "$status" = "true" ]
  then
    dunst_status='{"name":"dunst","instance":"dunst","color":"'"$red"'","markup":"none","full_text":"Notifications: OFF"}'
  else
    dunst_status='{"name":"dunst","instance":"dunst","color":"'"$green"'","markup":"none","full_text":"Notifications: ON"}'
  fi

  if (tailscale status | grep "Tailscale is stopped." > /dev/null)
  then
    tailscale_status='{"name":"tailscale","instance":"tailscale","color":"'"$foreground"'","markup":"none","full_text":"VPN: OFF"}'
  else
    tailscale_status='{"name":"tailscale","instance":"tailscale","color":"'"$green"'","markup":"none","full_text":"VPN: ON"}'
  fi

  status=$(dmenu-bluetooth --status)
  if [ "$status" = "" ]
  then
    bluetooth_status='{"name":"bluetooth","instance":"bluetooth","color":"'"$green"'","markup":"none","full_text":"'"$status"'"}'
  else
    bluetooth_status='{"name":"bluetooth","instance":"bluetooth","color":"'"$foreground"'","markup":"none","full_text":"'"$status"'"}'
  fi
}

# Override header
echo '{"version":1,"click_events": true}'

first_comma=""

# Run in a background process, ignore the first line, copy the second one
# directly and then wrap
( i3status | (read line && read line && echo "$line" && while :
do
  read line
  update
  echo "${first_comma}[${bluetooth_status},${tailscale_status},${dunst_status},${line#,\[}" | sed "s/#00FF00/$green/g" | sed "s/#FF0000/$red/g" | sed "s/#FFFF00/$yellow/" || exit 1
  first_comma=","
done) ) &

# TODO: maybe this can leak background process

# .process click events
while read line;
do
    line=$(echo $line | sed "s/^,//")
    echo $line >> /tmp/i3status.log
    name=$(echo $line | jq -r '.name')
    echo "''$name''" >> /tmp/i3status.log

    if [ "$name" = "dunst" ]
    then
        set-notification-pause toggle >> /tmp/i3status.log
    elif [ "$name" = "tailscale" ]
    then
       if (tailscale status | grep "Tailscale is stopped." > /dev/null)
       then
           tailscale up
       else
          tailscale down
       fi
    elif [ "$name" = "volume" ]
    then
      volume-change set-sink-mute @DEFAULT_SINK@ toggle
    elif [ "$name" = "wireless" ]
    then
      networkmanager_dmenu -l 10
    elif [ "$name" = "bluetooth" ]
    then
      dmenu-bluetooth -l 10 > /dev/null
    fi
done
