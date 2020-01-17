#! /bin/bash

setJournaldPersistent_LOGGING_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r add_conf_dir="/etc/systemd/journald.conf.d/"
  local -r add_storage_conf="${add_conf_dir}/storage.conf"

  if [[ ! -e "${add_storage_conf}" ]]; then
    mkdir /etc/systemd/journald.conf.d/
  fi
  if [[ ! -e "${add_storage_conf}" ]]; then
    touch "${add_storage_conf}"
  fi

  cat <<-END >"${add_storage_conf}"
[Journal]
Storage=persistent
END
  systemctl restart systemd-journald

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

cleanCfgDir_LOGGING_RUI() {
  local -r root_rsyslogd_dir="/etc/rsyslog.d"
  for f in "${root_rsyslogd_dir}/*"; do
    printf "Debug: [$FUNCNAME] file [$f]\n"
    mv "$f" "$f".orig
  done
}

deployCfg_LOGGING_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "${debug_prefix} ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  local -r root_rsyslogd_cfg="/etc/rsyslog.conf"

  if [ -e "${root_rsyslogd_cfg}.orig" ]; then
    printf "${debug_prefix} ${GRN_ROLLUP_IT} [rsyslogd] setup has already done. Pass. ${END_ROLLUP_IT} \n"
  else
    local -r rsyslogd_cfg="resources/logging/rsyslog.conf"

    systemctl stop rsyslogd

    cleanCfgDir_LOGGING_RUI
    mv "$root_rsyslogd_cfg" "${root_rsyslogd_cfg}.orig"
    cp "$rsyslogd_cfg" "/etc/"

    systemctl daemon-reload
    systemctl start rsyslogd
  fi
  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}
