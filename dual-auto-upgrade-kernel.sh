#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

# Level = "APP", = KMOD" (APP+Kernel Module), "ALL" (APP+Full kernel)
LEVEL=$1

alive=$(alive_test)
if [ x"$alive" != x"PASS" ]; then
        echo "ABORT: $alive"
        exit 0
fi

if [ x"$LEVEL" == x"" ]; then
	print_topic "Invalid option!"
	print_line "Use ./dual-auto-upgrade-kernel.sh APP|KMOD|ALL"
	exit
fi

# Delete previous authorized public keys
rm ${TC_HOME}/.ssh/authorized_keys
# Keep personal vscode private keys
cp ${TC_HOME}/.ssh/bong5-win-vscode.pub ${TC_HOME}/.ssh/authorized_keys

# Sometimes ssh session becomes invalid because IP changes in lab.
# So, we also delete known_hosts on upgrade which involves reboot
ssh-keygen -f "${TC_HOME}/.ssh/known_hosts" -R "${DUT_SSH_IPADDR}"
ssh-keygen -f "${TC_HOME}/.ssh/known_hosts" -R "${LP_SSH_IPADDR}"

# Update all network scripts in both DUT & LP
./install-network-script.sh DUT
./install-network-script.sh LP

if [ x"$LEVEL" == x"APP" ]; then
	print_banner "Upgrade APP Only: DONE!"
	exit
fi

# Upgrade kernel modules
if [ x"$LEVEL" == x"KMOD" ]; then
	print_banner "Upgrade APP + KMOD: DONE!"
	exit
fi

# reload kernel
./rollback-kernel-target.sh DUT
./rollback-kernel-target.sh LP
./upgrade-kernel-target.sh DUT ${UPGRADE_LINUX}
./upgrade-kernel-target.sh LP  ${UPGRADE_LINUX}
./reboot-target.sh DUT
./reboot-target.sh LP

print_banner "Upgrade APP + All Kernel: DONE!"
