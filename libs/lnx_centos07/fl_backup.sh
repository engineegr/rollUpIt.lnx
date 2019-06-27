#!/bin/bash

#:
#: fl_backup.sh
#:
#: It is a collection of functions to backup files with use of rdiff-backup
#:
#:
#: Install rdiff-backup
#:
installRdiffBackup_FLBACKUP_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local rc=0

  installEpel_SM_RUI
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't install epel ${END_ROLLUP_IT} \n"
    return $rc
  fi

  installPkg_COMMON_RUI "librsync" ""
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't install librsync ${END_ROLLUP_IT} \n"
    return $rc
  fi

  installPkg_COMMON_RUI "rdiff-backup" ""
  rc=$?

  if [ $rc -ne 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: can't install rdiff-backup ${END_ROLLUP_IT} \n"
    return $rc
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $rc
}

help_FLBACKUP_RUI() {
  echo "Usage: " >&2
  echo "-s <source dir>: a directory to be backup (local dir or ssh connection )" >&2
  echo "-d <destination>: where to backup (local dir or ssh connection )" >&2
  echo "-h : show help" >&2
}

checkArgs_FLBACKUP_RUI() {
  if [[ $1 =~ ^-[s/d/g/l/h]$ ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Invalid arguments [$1].\nSee help${END_ROLLUP_IT}\n"
    help_FLBACKUP_RUI
    exit 1
  fi
}

checkArgCount_FLBACKUP_RUI() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} enter the function ${END_ROLLUP_IT} \n"

  if [ $# -eq 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: no arguments has been passed.\nSee help: $(help_FLBACKUP_RUI) ${END_ROLLUP_IT}\n"
    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT}\n"
}

#:
#: Check if a remote dir or file exitsts
#:
#: arg1 - remote path
#: arg2 - error message
#:
checkRemoteFile() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} enter the function ${END_ROLLUP_IT} \n"
  local rc=255

  if [[ -z "$1" || -z "$2" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: NULL arguments ${END_ROLLUP_IT} \n"
    return $rc
  fi
  local -r rem_dir="$1"
  local -r remote_srv="${rem_dir%%:/*}"
  local -r remote_dir="${rem_dir#*:}"
  local -r err_msg="$2"

  printf "$debug_prefix ${GRN_ROLLUP_IT} Info: remote srv [$remote_srv] ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${GRN_ROLLUP_IT} Info: remote dir [$remote_dir] ${END_ROLLUP_IT} \n"

  local -r isDirExist=$(ssh $remote_srv "sh -c '([[ -e $remote_dir ]] && echo "true" || echo "false")'" 2>&1)
  rc=$?

  if [ $rc -ne 0 ]; then
    printf "$err_msg rc code: [$rc]"
    return $rc
  fi
  if [[ "$isDirExist" != true && "$isDirExist" != false ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Remote folder [$rem_dir] doesn't EXIST; see error received result [$isDirExist] ${END_ROLLUP_IT} \n"
    return 255
  elif [[ "$isDirExist" == false ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Remote folder [$rem_dir] doesn't EXIST; see received result [$isDirExist] ${END_ROLLUP_IT} \n"
    return 254
  fi
  printf "$debug_prefix ${GRN_ROLLUP_IT} INFO: Remote folder exists [$rem_dir]; see received result [$isDirExist] ${END_ROLLUP_IT} \n"

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT}\n"
  return $rc
}

#:
#: Create remote dir via ssh
#:
#: arg1 - dst dir
#: arg2 - err creation msg
#:
createRemDir() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local rc=255
  if [[ -z "$1" || -z "$2" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: NULL arguments ${END_ROLLUP_IT} \n"
    return $rc
  fi

  local -r rem_dir="$1"
  local -r remote_srv="${rem_dir%%:/*}"
  local -r remote_dir="${rem_dir#*:}"
  local -r err_msg="$2"

  checkRemoteFile "$rem_dir" "$err_msg"
  rc=$?
  if [[ $rc -ne 0 && $rc -ne 254 ]]; then
    return $rc
  fi
  # return 254 - the folder doesn't exists dir
  if [ $rc -eq 254 ]; then
    local -r res="$(ssh "$remote_srv" "mkdir -p $remote_dir" 2>&1)"
    rc=$?
    if [ $rc -ne 0 ]; then
      printf "$debug_prefix ${RED_ROLLUP_IT} Error: Can't create remote dir [$remote_dir]; remote srv [$remote_srv] \n\t See error message: [$res] ${END_ROLLUP_IT} \n"
      return $rc
    else
      printf "$debug_prefix ${CYN_ROLLUP_IT} INFO: Folder has been created successfully;\n\tSee received return code: [$rc];\n\tStdout/stderr [$res] ${END_ROLLUP_IT} \n"
    fi
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT}\n"
  return $?
}

checkLocalDir_FLBACKUP_RUI() {
  local -r dir=$1

  if [ ! -e $dir ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} ERROR: Invalid dir path: it doesn't exist. See help.\n ${END_ROLLUP_IT}\n"
    help_FLBACKUP_RUI
    exit 1
  fi
}

checkRemoteDir_FLBACKUP_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  local -r ssh_conn="$1"
  local -r rem_dir="${ssh_conn#*@}"
  local rc=0
  printf "$debug_prefix ${GRN_ROLLUP_IT} Atguments:\n\t"

  printf "$debug_prefix ssh_conn[$ssh_conn]\n"
  printf "$debug_prefix rem_dir[$rem_dir]\n"

  printf "${END_ROLLUP_IT} \n"

  checkRemoteFile "$rem_dir" "$debug_prefix ${RED_ROLLUP_IT} Error: Remote destination dir of the user doesn't exist [$rem_dir] ${END_ROLLUP_IT} \n"
  rc=$?
  if [[ $rc -ne 0 ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} ERROR: Invalid remote dir path: it doesn't exist. See help.\n ${END_ROLLUP_IT}\n"
    help_FLBACKUP_RUI
    exit 1
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
}

#:
#: arg001 - source (checking) dir
#: arg002 - isRemote
#:
checkDir_FLBACKUP_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"

  printf "$debug_prefix ${GRN_ROLLUP_IT} Arguments: src_dir[$1]"

  printf "${END_ROLLUP_IT}\n"
  local -r src_dir="$1"
  local __ref=$2
  local __res="false"

  if [[ -z "$(echo "$src_dir" | grep -P $DIR_NAME_REGEXP_ROLLUP_IT)" && -z "$(echo "$src_dir" | grep -P $REMDIR_REGEXP_ROLLUP_IT)" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} ERROR: Invalid passed arguments. See help.\n ${END_ROLLUP_IT}\n"
    help_FLBACKUP_RUI
    exit 1
  elif [[ -n "$(echo "$src_dir" | grep -P $DIR_NAME_REGEXP_ROLLUP_IT)" ]]; then
    checkLocalDir_FLBACKUP_RUI $src_dir
  elif [[ -n "$(echo "$src_dir" | grep -P $REMDIR_REGEXP_ROLLUP_IT)" ]]; then
    checkRemoteDir_FLBACKUP_RUI $src_dir

    __res="true"
    eval $__ref="'$__res'"
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT} \n"
  return $?
}

#:
#: Backup a dir
#:
#: arg1 - src dir
#: arg2 - dst dir
#: arg3 - log dir
#: arg4 - globbing file
#:
#: To restore
#: rdiff-backup --restore-as-of [1M 1W 1D 1H 1m] backup-dir dst-dir
#: To restore from increment file
#: rdiff-backup bakup_dir://rdiff-data-backups/increments/file.diff.gz dst/file
#: To list version (increments)
#: rdiff-backup -l backup-dir
#:
doBackup_FLBACKUP_RUI() {
  local -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  local rc=255

  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: NULL arguments ${END_ROLLUP_IT} \n"
    return $rc
  fi

  local src_dir="$1"
  local src_path="$src_dir"
  local dst_dir="$2"
  local dst_path="$dst_dir"
  local -r log_dir="$3"
  local -r glob_fl="$4"
  local isRemote="false"

  printf "$debug_prefix ${GRN_ROLLUP_IT} Atguments:\n\t"

  printf "$debug_prefix src_dir[$src_dir]\n"
  printf "$debug_prefix dst_dir[$dst_dir]\n"
  printf "$debug_prefix log_dir[$log_dir]\n"
  printf "$debug_prefix glob_fl[$glob_fl]\n"

  printf "${END_ROLLUP_IT} \n"

  checkDir_FLBACKUP_RUI $src_dir isRemote
  if [[ "$isRemote" == "true" ]]; then
    src_dir="${src_dir/:/::}"
    src_path="$(echo "$src_dir" | sed -E "s/(.*)\:\:(.*)/\2/")"
  fi

  checkDir_FLBACKUP_RUI $dst_dir isRemote
  if [[ "$isRemote" == "true" ]]; then
    dst_dir="${dst_dir/:/::}"
    dst_path="$(echo "$dst_dir" | sed -E "s/(.*)\:\:(.*)/\2/")"
  fi

  if [ ! -e "$log_dir" ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: There is no [$log_dir] log dir ${END_ROLLUP_IT} \n"
    return $rc
  fi

  if [[ -n "$glob_fl" && ! -e "$glob_fl" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: There is no [$glob_fl] globbing file ${END_ROLLUP_IT} \n"
    return $rc
  fi

  local dst_name=""

  if [[ -n "$(echo "$src_path" | grep -P "^~\/?$")" ]]; then
    if [[ -n "$(echo "$src_path" | grep -P "^~$")" ]]; then
      dst_name="root"
    else
      dst_name="home"
    fi
  else
    dst_name="$(echo "$src_path" | sed -E "s/([[:alnum:]\.\-\_\~\/\*]+)\/([[:alnum:]\-\_\~\*]+)\/?/\2/")"
  fi

  printf "$debug_prefix ${RED_ROLLUP_IT} dst_name [$dst_name] ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${RED_ROLLUP_IT} dst_path [$dst_path] ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${RED_ROLLUP_IT} src_path [$src_path] ${END_ROLLUP_IT} \n"

  if [ -n "$glob_fl" ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} glob_fl [$glob_fl] ${END_ROLLUP_IT} \n"
    rdiff-backup -v5 --print-statistics --force --create-full-path \
      --exclude-globbing-filelist "$glob_fl" "$src_dir" "$dst_dir" \
      2>&1 | tee "${log_dir}/bck_$(date +%H%M_%Y%m%d)_${dst_name}_rdiff_backup.log"
  else
    rdiff-backup -v5 --print-statistics --force --create-full-path --exclude-special-files "$src_dir" "$dst_dir" 2>&1 | tee "${log_dir}/bck_$(date +%H%M_%Y%m%d)_${dst_name}_rdiff_backup.log"
  fi

  rc=$?
  printf "$debug_prefix ${GRN_ROLLUP_IT} Info: [$rc] return code ${END_ROLLUP_IT} \n"
  if [ $rc -ne 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Can't make backup [$rc] error code ${END_ROLLUP_IT} \n"
    return $rc
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT}\n"
  rc=$?

  return $rc
}

#:
#: Clean up a backup dir
#:
#: arg1 - src dir
#: arg2 - clean older than
#: arg3 - log dir
#: arg4 - globbing file
#:
#: To restore
#: rdiff-backup --restore-as-of [1M 1W 1D 1H 1m] backup-dir dst-dir
#: To restore from increment file
#: rdiff-backup bakup_dir://rdiff-data-backups/increments/file.diff.gz dst/file
#: To list version (increments)
#: rdiff-backup -l backup-dir
#:
doCleanup_FLBACKUP_RUI() {
  declare -r debug_prefix="debug: [$0] [ $FUNCNAME ] : "
  printf "$debug_prefix ${GRN_ROLLUP_IT} ENTER the function ${END_ROLLUP_IT} \n"
  local rc=255

  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: NULL arguments ${END_ROLLUP_IT} \n"
    return $rc
  fi

  local src_dir="$1"
  local -r older_than="$2"
  local -r log_dir="$3"
  local isRemote="false"

  printf "$debug_prefix ${GRN_ROLLUP_IT} Atguments:\n\t"

  printf "$debug_prefix src_dir[$src_dir]\n"
  printf "$debug_prefix older_than[$older_than]\n"
  printf "$debug_prefix log_dir[$log_dir]\n"

  printf "${END_ROLLUP_IT} \n"

  checkDir_FLBACKUP_RUI $src_dir isRemote
  if [[ "$isRemote" == "true" ]]; then
    src_dir="${src_dir/:/::}"
  fi

  if [ ! -e "$log_dir" ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: There is no [$log_dir] log dir ${END_ROLLUP_IT} \n"
    return $rc
  fi

  if [[ -n "$glob_fl" && ! -e "$glob_fl" ]]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: There is no [$glob_fl] globbing file ${END_ROLLUP_IT} \n"
    return $rc
  fi

  local src_name=""

  if [[ -n "$(echo "$src_path" | grep -P "^~\/?$")" ]]; then
    if [[ -n "$(echo "$src_path" | grep -P "^~$")" ]]; then
      src_name="root"
    else
      src_name="home"
    fi
  else
    src_name="$(echo "$src_path" | sed -E "s/([[:alnum:]\.\-\_\~\/\*]+)\/([[:alnum:]\-\_\~\*]+)\/?/\2/")"
  fi

  printf "$debug_prefix ${RED_ROLLUP_IT} src_dir [$src_dir] ${END_ROLLUP_IT} \n"
  printf "$debug_prefix ${RED_ROLLUP_IT} src_name [$src_name] ${END_ROLLUP_IT} \n"

  rdiff-backup --remove-older-than "$older_than" "$src_dir" 2>&1 | tee "$log_dir/rm_oldbck_$(date +%H%M_%Y%m%d)_${src_name}.rdiff_backup.log"
  rc=$?
  if [ $rc -ne 0 ]; then
    printf "$debug_prefix ${RED_ROLLUP_IT} Error: Can't make cleaning up the old backup; older than [$older_than] ${END_ROLLUP_IT} \n"
    return $rc
  fi

  printf "$debug_prefix ${GRN_ROLLUP_IT} RETURN the function ${END_ROLLUP_IT}\n"
  rc=$?

  return $rc
}
