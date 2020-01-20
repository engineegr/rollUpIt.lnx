#!/bin/bash

############################################
### Configuring Bind9 DNS Server ### #######
############################################

prepare_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -rg BIND9_SYSMD_SERVICE_RUI="bind"

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}

install_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  declare -Ar local install_pkgs=(
    "bind9" "bind9-doc" "bind9utils"
  )
  installPkgList_COMMON_RUI install_pkgs
  pip3 install pyyaml j2cli

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

compileConfig_BIND9_RUI() {
  local debug_prefix="debug: [$0] [ $FUNCNAME[0] ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  declare -Ar bindCfgMap=(
    ["named.conf.j2"]="ns.yml"
    ["named.conf.options.j2"]="ns.yml"
    ["named.conf.local.j2"]="ns.yml"
    ["named.conf.default-zones.j2"]="ns.yml"
    ["named.conf.log.j2"]="ns.yml"
    ["db.srvfarm.labs.net.j2"]="zone_srvfarm.yml"
    ["db.inv.srvfarm.labs.net.j2"]="inv_zone_srvfarm.yml"
  )
  local -r out_path="${ROOT_DIR_ROLL_UP_IT}/resources/bind9/out/etc/bind"
  if [[ -e "${out_path}" ]]; then
    rm -Rf "${out_path}"
  fi
  mkdir -p "${out_path}"

  for key in "${!bindCfgMap[@]}"; do
    local templ_fp="${ROOT_DIR_ROLL_UP_IT}/resources/bind9/$key"
    local cfg_fp="${out_path}/${key%%.j2}"
    j2 -f yaml --customize "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/j2_cust.py" "${templ_fp}" "${ROOT_DIR_ROLL_UP_IT}/resources/bind9/${bindCfgMap[${key}]}" >"${cfg_fp}"
  done

  printf "$debug_prefix ${GRN_ROLLUP_IT} EXIT the function ${END_ROLLUP_IT} \n"
}
