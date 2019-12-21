#! /bin/bash

ROOT_DIR_ROLL_UP_IT="/usr/local/src/post-scripts/rollUpIt.lnx"

main() {
  local -r patch_path="${ROOT_DIR_ROLL_UP_IT}/resources/iptables/lnx_debian09/15-ip4tables_22122019.patch"
  local -r dest_fp="/usr/share/netfilter-persistent/plugins.d/15-ip4tables"

  if [[ ! -e ${patch_fp} || ! -e ${dest_fp} ]]; then
    echo "Error: invalid ${patch_fp} or ${dest_fp}"
    exit 1
  else
    patch "${dest_fp}" <"${patch_path}"
  fi
}
