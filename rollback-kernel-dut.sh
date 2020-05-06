#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

#Roll-back version
RB_VER=$1

echo -e "Rollback kernel version=$RB_VER"
run_dut "mv /boot/bzImage-kernel-${RB_VER}.backup       /boot/bzImage-kernel"
run_dut "mv /boot/config-${RB_VER}.backup               /boot/config-${RB_VER}"
run_dut "mv /boot/System.map-${RB_VER}.backup           /boot/System.map-${RB_VER}"
run_dut "mv /lib/modules/${RB_VER}.backup               /lib/modules/${RB_VER}"
# Uncomment if Linux system contain module symbols package
# run_dut "mv /boot/Module.symvers-${RB_VER}.backup       /boot/Module.symvers-${RB_VER}"

print_separator
run_dut "ls /boot | grep ${RB_VER}"
run_dut "ls /lib/modules | grep ${RB_VER}"
print_banner "Rollbacked to kernel version=$RB_VER"
