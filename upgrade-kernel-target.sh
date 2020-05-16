#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

ROLE=$1
set_target $ROLE
LINUXTARBALL=$2

TARGET_HOME=$(role2home $ROLE)
ROLE_SSH_IPADDR=$(role2sshipaddr $ROLE)

LINUX_WORKDIR=work
LINUX_TOPDIR=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_WORKDIR}/).*(?=/)")
UPGRADE_VER=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_TOPDIR}/linux-).*(?=-x86)")
LINUX_PACKAGE=$(echo $LINUXTARBALL | grep -o -P "(?<=${LINUX_TOPDIR}/).*")

TARGET_DST="/home/root/temp"

print_banner "install $LINUX_PACKAGE @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"
run_target "rm -rf ${TARGET_DST}"
run_target "mkdir -p ${TARGET_DST}"
scp2target $LINUXTARBALL ${TARGET_DST}
run_target "cd ${TARGET_DST}; tar xf ${LINUX_PACKAGE}"

# Make sure TARGET has rescue script so that if kernel fail to boot, at least
# we can at GRUB edit to "GOLD-bzImage-kernel" and trigger it from serial
# console.
print_line "scp rescue_os.sh script @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"
scp2target rescue_os.sh ${TARGET_HOME}

# Run the rescue_os.sh script to at least make sure we have gold version
# on the TARGET
run_target "cd ${TARGET_HOME}; chmod a+x rescue_os.sh; source ./rescue_os.sh"
CUR_VER=$(run_target_silence "uname -r")

# Back-Up Current version
print_line "Backup kernel version=$CUR_VER @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"
run_target "cp /boot/bzImage-kernel            /boot/BACKUP-bzImage-kernel-${CUR_VER}"
run_target "cp /boot/config-${CUR_VER}         /boot/BACKUP-config-${CUR_VER}"
run_target "cp /boot/System.map-${CUR_VER}     /boot/BACKUP-System.map-${CUR_VER}"
run_target "mv /lib/modules/${CUR_VER}         /lib/modules/BACKUP-${CUR_VER}"

# Populate new kernel ingredients
print_line "Install kernel version=$UPGRADE_VER @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"
run_target "cp $TARGET_DST/boot/vmlinuz-${UPGRADE_VER}       /boot/bzImage-kernel"
run_target "cp $TARGET_DST/boot/config-${UPGRADE_VER}        /boot/"
run_target "cp $TARGET_DST/boot/System.map-${UPGRADE_VER}    /boot/"
run_target "mv $TARGET_DST/lib/modules/${UPGRADE_VER}        /lib/modules/"
#run_target "cp $TARGET_DST/boot/Module.symvers-${UPGRADE_VER}       /boot/"

# Store the LINUX version that is used for current booting
run_target "echo ${UPGRADE_VER} > ${TESTVER_FILE}"
run_target "echo ${CUR_VER} > ${BACKUPVER_FILE}"

print_separator
run_target "ls /boot"
run_target "ls /lib/modules/"
print_separator

unset_target
print_banner "To rollback > ./rollback-kernel-target.sh"
