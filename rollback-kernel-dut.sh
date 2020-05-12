#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

#Roll-back version
RB_VER=$1
RM_VER=$2

echo -e "Delete upgraded kernel version=$RM_VER"
run_dut "rm /boot/bzImage-kernel"
run_dut "rm /boot/config-${RM_VER}"
run_dut "rm /boot/System.map-${RM_VER}"
run_dut "rm -rf /lib/modules/${RM_VER}"
run_dut "rm ${TESTVER_FILE}"

echo -e "Rollback kernel version=$RB_VER"
run_dut "mv /boot/BACKUP-bzImage-kernel-${RB_VER}    /boot/bzImage-kernel"
run_dut "mv /boot/BACKUP-config-${RB_VER}           /boot/config-${RB_VER}"
run_dut "mv /boot/BACKUP-System.map-${RB_VER}       /boot/System.map-${RB_VER}"
run_dut "mv /lib/modules/BACKUP-${RB_VER}           /lib/modules/${RB_VER}"

print_separator
run_dut "ls /boot | grep ${RB_VER}"
run_dut "ls /lib/modules | grep ${RB_VER}"
print_banner "Rollbacked to kernel version=$RB_VER"
