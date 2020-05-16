#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

alive=$(alive_test)
if [ x"$alive" != x"PASS" ]; then
        echo "ABORT: $alive"
        exit 0
fi

# Delete previous authorized public keys
rm ${TC_HOME}/.ssh/authorized_keys

# Update all network scripts in both DUT & LP
./install-network-script.sh DUT
./install-network-script.sh LP

# reload kernel 
./rollback-kernel-target.sh DUT
./rollback-kernel-target.sh LP 
./upgrade-kernel-target.sh DUT ${UPGRADE_LINUX}
./upgrade-kernel-target.sh LP  ${UPGRADE_LINUX}
./reboot-target.sh DUT
./reboot-target.sh LP
