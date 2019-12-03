#! /bin/bash

ROOT_DIR_ROLL_UP_IT="/usr/local/src/rollUpIt.lnx"

/usr/bin/env -i "$(cat "${ROOT_DIR_ROLL_UP_IT}"/resources/cron-env)" "$@"
