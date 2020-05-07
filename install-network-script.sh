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

# Create new DUT ssh public key and add that to Test Center for scp test log
run_dut "rm -rf ${DUT_HOME}/.ssh"
run_dut 'cat /dev/zero | ssh-keygen -q -N ""'
run_dut_silence "cat ${DUT_HOME}/.ssh/id_rsa.pub" >> ${TC_HOME}/.ssh/authorized_keys
run_dut 'dmidecode -t 1 | grep "Product Name" | cut -d":" -f2 > ~/.machinename'
run_dut "scp -o StrictHostKeyChecking=no ~/.machinename ${TC_USER}@${TC_IPADDR}:${TC_HOME}/dut-machine"

# Create new LP ssh public key and add that to Test Center for scp test log
run_lp "rm -rf ${LP_HOME}/.ssh"
run_lp 'cat /dev/zero | ssh-keygen -q -N ""'
run_lp_silence "cat ${LP_HOME}/.ssh/id_rsa.pub" >> ${TC_HOME}/.ssh/authorized_keys
run_lp 'dmidecode -t 1 | grep "Product Name" | cut -d":" -f2 > ~/.machinename'
run_lp "scp -o StrictHostKeyChecking=no ~/.machinename ${TC_USER}@${TC_IPADDR}:${TC_HOME}/lp-machine"
