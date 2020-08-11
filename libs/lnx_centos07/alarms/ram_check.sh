#! /bin/bash

THRESHOLD='10'

alarm_msg="$(free -t -hl | awk -v th=$THRESHOLD '/Total/{ sub("M", "", $4); if (int($4) < th) { print "[Alarm] Free RAM: " $4 " [M] less than " th " [M]"; } }')"

if [ -n "${alarm_msg}" ]; then
  while IFS= read -r u; do
    username="$(echo $u | awk '{print $1}')"
    t="$(echo $u | awk '{print $2}')"
    echo "u: $u"
    if [ -n "$(echo $u | grep -E '(gonzo|root)')" ]; then
      echo "${alarm_msg}" | write $username $t
    fi
  done < <(who)

  echo "$(hostname) MSG ${alarm_msg}"
fi
