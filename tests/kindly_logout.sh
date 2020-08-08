#! /bin/bash

user_name="${1:-}"
time_threshold='10s'

if [ -z ${user_name} ]; then
  echo "[Error] Please, specify user name"
  exit 1
fi

user_pid="$(who -a | awk 'NR>2{ print $1 ":" $7; }' | grep ${user_name} | cut -d: -f2)"

msg_tosend="[Info] Dear, ${user_name}. You will be kicked off in ${time_threshold}. Have a good day!"
if [ -z ${user_pid} ]; then
  echo "[Warrning] Couldn't find the user session"
  exit 1
else
  user_ip="$(w -i | awk 'NR>2{ print $1 ":" $3;}' | grep ${user_name} | cut -d: -f2)"
  if [ -z ${user_ip} ]; then
    user_ip='N/A'
  fi
  echo "[Info] We will send a msg [${msg_tosend}] to the user [${user_name} : ${user_pid} : ${user_ip}]"
fi

echo "[Info] Dear, ${user_name}. You will be kicked off in ${time_threshold}. Have a good day!" | write ${user_name}
sleep ${time_threshold} && kill -9 ${user_pid} &
echo "[Info] End the script"
