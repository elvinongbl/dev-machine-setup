#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

LINUX_WORKDIR=work

LINUXTARBALL=$1
LINUX_TOPDIR=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_WORKDIR}/).*(?=/)")
UPGRADE_VER=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_TOPDIR}/linux-).*(?=-x86)")
LINUX_PACKAGE=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_TOPDIR}/).*")

DUT_DST=/home/root/temp

run_dut "rm -rf $DUT_DST"
run_dut "mkdir -p $DUT_DST"
scp2dut $LINUXTARBALL $DUT_DST
run_dut "cd $DUT_DST; tar xf ${LINUX_PACKAGE}"

# Make sure DUT has rescue script so that if kernel fail to boot, at least
# we can at GRUB edit to "GOLD-bzImage-kernel" and trigger it from serial
# console.
echo "scp rescue_os.sh script to DUT($DUT_SSH_IPADDR)"
scp rescue_os.sh root@$DUT_SSH_IPADDR:${DUT_HOME}

# Run the rescue_os.sh script to at least make sure we have gold version
# on the DUT
run_dut "cd ${DUT_HOME}; chmod a+x rescue_os.sh; source ./rescue_os.sh"
CUR_VER=$(run_dut_silence "uname -r")

# Back-Up Current version
echo -e "Backup kernel vrsion=$CUR_VER"
run_dut "cp /boot/bzImage-kernel            /boot/BACKUP-bzImage-kernel-${CUR_VER}"
run_dut "cp /boot/config-${CUR_VER}         /boot/BACKUP-config-${CUR_VER}"
run_dut "cp /boot/System.map-${CUR_VER}     /boot/BACKUP-System.map-${CUR_VER}"
run_dut "mv /lib/modules/${CUR_VER}         /lib/modules/BACKUP-${CUR_VER}"

# Populate new kernel ingredients
echo -e "Install kernel version=$UPGRADE_VER"
run_dut "cp $DUT_DST/boot/vmlinuz-${UPGRADE_VER}       /boot/bzImage-kernel"
run_dut "cp $DUT_DST/boot/config-${UPGRADE_VER}        /boot/"
run_dut "cp $DUT_DST/boot/System.map-${UPGRADE_VER}    /boot/"
run_dut "mv $DUT_DST/lib/modules/${UPGRADE_VER}        /lib/modules/"
#run_dut "cp $DUT_DST/boot/Module.symvers-${UPGRADE_VER}       /boot/"

# Store the LINUX version that is used for current booting
run_dut "echo ${UPGRADE_VER} > ${TESTVER_FILE}"

print_separator
run_dut "ls /boot | grep ${UPGRADE_VER}"
run_dut "ls /lib/modules/ | grep ${UPGRADE_VER}"
print_banner "Rollback Cmd > ./rollback-kernel-dut.sh $CUR_VER $UPGRADE_VER"
