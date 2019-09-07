#!/bin/bash

main() {
  local -r user_name="likhobabin_im"

  sudo install -d -o "$user_name" /run/user/$(id -u ${user_name})
  sudo systemctl start user@$(id -u ${user_name})
  sudo -u ${user_name} DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u ${user_name})/bus systemctl --user
}

main $@
