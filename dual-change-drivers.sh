#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

alive=$(targets_alive_test)
if [ x"$alive" != x"PASS" ]; then
        echo "ABORT: $alive"
        # Comment here for the first update
        exit 0
fi

# Delete previous authorized public keys
rm ${TC_HOME}/.ssh/authorized_keys
# Keep personal vscode private keys
cp ${TC_HOME}/.ssh/bong5-win-vscode.pub ${TC_HOME}/.ssh/authorized_keys

# Sometimes ssh session becomes invalid because IP changes in lab.
# So, we also delete known_hosts on upgrade which involves reboot
ssh-keygen -f "${TC_HOME}/.ssh/known_hosts" -R "${DUT_SSH_IPADDR}"
ssh-keygen -f "${TC_HOME}/.ssh/known_hosts" -R "${LP_SSH_IPADDR}"

KMOD_DIR="drivers/net/ethernet/stmicro/stmmac"

# Update kernel driver and reload
./upgrade-driver-target.sh DUT ${UPGRADE_LINUX_BUILD} ${KMOD_DIR}
./upgrade-driver-target.sh LP  ${UPGRADE_LINUX_BUILD} ${KMOD_DIR}
run_dut "modprobe -r stmmac_pci && modprobe -r stmmac"
run_dut "modprobe stmmac && modprobe stmmac_pci"
run_lp  "modprobe -r stmmac_pci && modprobe -r stmmac"
run_lp  "modprobe stmmac && modprobe stmmac_pci"

print_banner "Upgrade Kernel Modules: DONE!"
