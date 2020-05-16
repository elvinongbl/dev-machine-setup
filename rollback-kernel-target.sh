#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

ROLE=$1
set_target $ROLE
ROLE_SSH_IPADDR=$(role2sshipaddr $ROLE)

print_banner "Rollback kernel @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"

#Roll-back version
RB_VER=$(run_target_silence "cat ${BACKUPVER_FILE}")
RM_VER=$(run_target_silence "cat ${TESTVER_FILE}")

if [ x"$RB_VER" == x"" ] || [ x"$RM_VER" == x"" ]; then
        echo "Rollback = $RB_VER or Remove = $RM_VER is not defined"
        exit 0
else
        echo "Rollback = $RB_VER or Remove = $RM_VER Found"
fi

print_topic "Delete upgraded kernel version=$RM_VER"
run_target "rm /boot/bzImage-kernel"
run_target "rm /boot/config-${RM_VER}"
run_target "rm /boot/System.map-${RM_VER}"
run_target "rm -rf /lib/modules/${RM_VER}"
run_target "rm ${TESTVER_FILE}"

print_topic "Rollback kernel version=$RB_VER"
run_target "mv /boot/BACKUP-bzImage-kernel-${RB_VER}    /boot/bzImage-kernel"
run_target "mv /boot/BACKUP-config-${RB_VER}           /boot/config-${RB_VER}"
run_target "mv /boot/BACKUP-System.map-${RB_VER}       /boot/System.map-${RB_VER}"
run_target "mv /lib/modules/BACKUP-${RB_VER}           /lib/modules/${RB_VER}"
run_target "rm ${BACKUPVER_FILE}"

print_separator
run_target "ls /boot"
run_target "ls /lib/modules"
print_separator

unset_target
print_banner "Rollbacked to kernel version=$RB_VER"
