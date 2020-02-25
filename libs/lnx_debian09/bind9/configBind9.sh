#!/bin/bash

############################################
### Configuring Bind9 DNS Server ### #######
############################################

prepare_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -rg BIND9_SYSMD_SERVICE_RUI="bind9"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

install_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  local -r install_pkgs=(
    "bind9" "bind9-doc" "bind9utils"
  )
  installPkgList_COMMON_RUI install_pkgs
  pip3.7 install pyyaml j2cli

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

start_BIND9_RUI() {
  systemctl start "$BIND9_SYSMD_SERVICE_RUI"
  onFailed_SM_RUI $? "Can't start Bind9 service"
}

stop_BIND9_RUI() {
  systemctl stop "$BIND9_SYSMD_SERVICE_RUI"
  onFailed_SM_RUI $? "Can't stop Bind9 service"
}

checkConfigFileSet_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

compileZone_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -Ar bindCfgMap=(
    ["db.zone.j2"]="zone.yml"
    ["db.inv_zone.j2"]="inv_zone.yml"
  )

  local -r out_path="${ROOT_DIR_ROLL_UP_IT}/resources/bind9/out/etc/bind"
  local -r zone_name="$(cat ${ROOT_DIR_ROLL_UP_IT}/resources/bind9/db/zone.yml |
    grep -E '^([ ]*name\:\s".*")$' | sed -E 's/\s*name:\s"(.*)"/\1/g')"

  local -r zone_out_path="${out_path}/db/${zone_name}"

  if [[ -e "${zone_out_path}" ]]; then
    rm -Rf "${zone_out_path}"
  fi
  mkdir -p "${zone_out_path}"

  j2 -f yaml --customize "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/j2_cust.py" \
    "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/db/db.zone.j2" \
    "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/db/zone.yml" \
    >"${zone_out_path}/db.${zone_name}"

  j2 -f yaml --customize "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/j2_cust.py" \
    "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/db/db.inv_zone.j2" \
    "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/db/inv_zone.yml" \
    >"${zone_out_path}/db.inv.${zone_name}"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

#
# arg1 - path to nameserver yml content path
#
compileConfig_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  if [ -z "$1" ]; then
    onFailed_SM_RUI "1" "Error: no nameserver yml content file name was passed"
    exit 1
  fi

  local -r ns_yml="$1"

  declare -Ar bindCfgMap=(
    ["named.conf.j2"]="${ns_yml}"
    ["named.conf.options.j2"]="${ns_yml}"
    ["named.conf.local.j2"]="${ns_yml}"
    ["named.conf.default-zones.j2"]="${ns_yml}"
    ["named.conf.log.j2"]="${ns_yml}"
    ["rndc_keys.conf.j2"]="${ns_yml}"
    ["dnskeys.conf.j2"]="${ns_yml}"
  )
  local -r out_path="${ROOT_DIR_ROLL_UP_IT}/resources/bind9/out/etc/bind"
  if [ -e "${out_path}" ]; then
    rm -Rf "${out_path}"
  fi
  mkdir -p "${out_path}"

  for key in "${!bindCfgMap[@]}"; do
    local templ_fp="${ROOT_DIR_ROLL_UP_IT}/resources/bind9/$key"
    if [ ! -e "${templ_fp}" ]; then
      onFailed_SM_RUI "1" "Error: the nameserver yml content file doesn't exist"
      exit 1
    fi

    local cfg_fp="${out_path}/${key%%.j2}"
    j2 -f yaml --customize "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/j2_cust.py" \
      "${templ_fp}" \
      "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/${bindCfgMap[${key}]}" >"${cfg_fp}"
  done

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

deployZone_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r bck_config_fp="/etc/bind_$(date +%Y%m_%H%M%S)"
  local -r src_path="${ROOT_DIR_ROLL_UP_IT}/resources/bind9/out/etc/bind/db/"
  local -r dst_path="/etc/bind/db/"
  stop_BIND9_RUI
  cp -Rf "${dst_path}" "${bck_config_fp}"
  rsync -vrut "${src_path}" "${dst_path}"
  start_BIND9_RUI

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

deployConfig_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r bck_config_fp="/etc/bind_$(date +%Y%m_%H%M%S)"
  local -r src_path="${ROOT_DIR_ROLL_UP_IT}/resources/bind9/out/etc/bind/"
  local -r dst_path="/etc/bind/"
  stop_BIND9_RUI
  cp -Rf "${dst_path}" "${bck_config_fp}"
  rsync -vrut "${src_path}" "${dst_path}"
  start_BIND9_RUI

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
