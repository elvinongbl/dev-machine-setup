#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

#Roll-back version
RB_VER=$(run_dut_silence "cat ${BACKUPVER_FILE}")
RM_VER=$(run_dut_silence "cat ${TESTVER_FILE}")

if [ x"$RB_VER" == x"" ] || [ x"$RM_VER" == x"" ]; then
        echo "Rollback = $RB_VER or Remove = $RM_VER is not defined"
        exit 0
else
        echo "Rollback = $RB_VER or Remove = $RM_VER Found"
fi

print_topic "Delete upgraded kernel version=$RM_VER"
run_dut "rm /boot/bzImage-kernel"
run_dut "rm /boot/config-${RM_VER}"
run_dut "rm /boot/System.map-${RM_VER}"
run_dut "rm -rf /lib/modules/${RM_VER}"
run_dut "rm ${TESTVER_FILE}"

print_topic "Rollback kernel version=$RB_VER"
run_dut "mv /boot/BACKUP-bzImage-kernel-${RB_VER}    /boot/bzImage-kernel"
run_dut "mv /boot/BACKUP-config-${RB_VER}           /boot/config-${RB_VER}"
run_dut "mv /boot/BACKUP-System.map-${RB_VER}       /boot/System.map-${RB_VER}"
run_dut "mv /lib/modules/BACKUP-${RB_VER}           /lib/modules/${RB_VER}"
run_dut "rm ${BACKUPVER_FILE}"

print_separator
run_dut "ls /boot"
run_dut "ls /lib/modules"
print_separator

print_banner "Rollbacked to kernel version=$RB_VER"
