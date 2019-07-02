#!/bin/bash

set -o xtrace
set -o errexit

function main() {
  local -r session_name="lim_env"
  local -r is_session=$(tmux list-session | awk '{ print $1 }' | grep "$session_name")

  if [[ -z $is_session ]]; then
    tmux new-session -d -s "$session_name" -n disk_usage
    tmux send-keys -t disk_usage 'df -hl' Enter

    tmux new-window -t "$session_name":2 -n dmesg
    tmux send-keys -t "$session_name":2 'sudo dmesg --human --color=always -e | more' Enter

    tmux new-window -t "$session_name":3 -n part_usage
    tmux send-keys -t "$session_name":3 'sudo du -d 1 -h -BM --exclude "proc" /' Enter

    tmux new-window -t "$session_name":4 -n top 'top'

    tmux new-window -t "$session_name":5 -n start_wnd
  fi
  tmux -2 attach-session -d -t "$session_name"
}

main $@
