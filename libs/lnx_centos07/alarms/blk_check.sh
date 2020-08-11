#! /bin/bash

THRESHOLD='75'

alarm_msg="$(df -hl -Bg | awk -v th="$THRESHOLD" ' \
  { \
    if (FNR > 1) { \
      sub(/\%/,"",$5); \
      if ($5 > th) { \
        blk_map[$1] = $3 "/" $2 " " $5 "%"; \
      } \
    } \
  } \
  END { \
  for (b in blk_map) \
    { print b " : " blk_map[b]; } \
    }')"

if [ -n "${alarm_msg}" ]; then
  echo -e "[Alarm] $(hostname) Storage space is exhausting (less than $THRESHOLD %).\n$alarm_msg"
fi
