#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

ROLE=$1
set_target $ROLE
LINUXBUILD=$2
LINUXKMOD=$3

TARGET_HOME=$(role2home $ROLE)
ROLE_SSH_IPADDR=$(role2sshipaddr $ROLE)

KMOD_LIST=$(ls $LINUXBUILD/$LINUXKMOD/*.ko)

CUR_VER=$(run_target_silence "uname -r")
TARGET_DST="/lib/modules/${CUR_VER}/kernel/${LINUXKMOD}"

print_banner "install ${KMOD_LIST} @@ TARGET($ROLE@$ROLE_SSH_IPADDR:$TARGET_DST)"
scp2target "$KMOD_LIST" ${TARGET_DST}

print_banner "scp integrity check"
md5sum ${KMOD_LIST}

print_separator
run_target "cd ${TARGET_DST}; md5sum *.ko"
print_separator

unset_target
