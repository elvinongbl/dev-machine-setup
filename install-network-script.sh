#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

echo "scp network-script to DUT($DUT_SSH_IPADDR)"
run_dut "rm -rf ${NETSCRIPT_INSTALL}"
run_dut "mkdir -p ${NETSCRIPT_INSTALL}"
scp -r network-script/* root@$DUT_SSH_IPADDR:${NETSCRIPT_INSTALL}

echo "scp network-script to LP($LP_SSH_IPADDR)"
run_lp "rm -rf ${NETSCRIPT_INSTALL}"
run_lp "mkdir -p ${NETSCRIPT_INSTALL}"
scp -r network-script/* root@$LP_SSH_IPADDR:${NETSCRIPT_INSTALL}
