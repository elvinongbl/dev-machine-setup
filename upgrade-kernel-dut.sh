#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

LINUX_WORKDIR=work

LINUXTARBALL=$1
LINUX_TOPDIR=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_WORKDIR}/).*(?=/)")
LINUX_VERSION=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_TOPDIR}/linux-).*(?=-x86)")
LINUX_PACKAGE=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_TOPDIR}/).*")

DUT_DST=/home/root/temp

run_dut "rm -rf $DUT_DST"
run_dut "mkdir -p $DUT_DST"
scp2dut $LINUXTARBALL $DUT_DST
run_dut "cd $DUT_DST; tar xf ${LINUX_PACKAGE}"

# Make a kernel back-up
BACKUP_VERSION=$(run_dut_silence "uname -r")
echo -e "Back kernel version=$BACKUP_VERSION"
run_dut "mv /boot/bzImage-kernel                        /boot/bzImage-kernel-${BACKUP_VERSION}.backup"
run_dut "mv /boot/config-${BACKUP_VERSION}              /boot/config-${BACKUP_VERSION}.backup"
run_dut "mv /boot/System.map-${BACKUP_VERSION}          /boot/System.map-${BACKUP_VERSION}.backup"
# Uncomment if Linux system contain module symbols package
#run_dut "mv /boot/Module.symvers-${BACKUP_VERSION}      /boot/Module.symvers-${BACKUP_VERSION}.backup"
run_dut "mv /lib/modules/${BACKUP_VERSION}              /lib/modules/${BACKUP_VERSION}.backup"

# Populate new kernel ingredients
echo -e "Install kernel version=$LINUX_VERSION"
run_dut "cp $DUT_DST/boot/vmlinuz-${LINUX_VERSION}              /boot/bzImage-kernel"
run_dut "cp $DUT_DST/boot/config-${LINUX_VERSION}               /boot/"
run_dut "cp $DUT_DST/boot/System.map-${LINUX_VERSION}           /boot/"
run_dut "mv $DUT_DST/lib/modules/${LINUX_VERSION}               /lib/modules/"
# Uncomment if Linux system contain module symbols package
#run_dut "cp $DUT_DST/boot/Module.symvers-${LINUX_VERSION}       /boot/"

print_separator
run_dut "ls /boot | grep ${LINUX_VERSION}"
run_dut "ls /lib/modules/ | grep ${LINUX_VERSION}"
print_banner "Rollback kernel version = $BACKUP_VERSION"
