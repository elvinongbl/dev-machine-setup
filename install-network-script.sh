#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

echo "scp network-script to DUT($DUT_SSH_IPADDR)"
run_dut "rm -rf ${NETSCRIPT_INSTALL}"
run_dut "mkdir -p ${NETSCRIPT_INSTALL}"
scp -r network-script/* root@$DUT_SSH_IPADDR:${NETSCRIPT_INSTALL}
run_dut "echo ${DUT_REPORT} > ${NETSCRIPT_INSTALL}/devrole.txt"

echo "scp network-script to LP($LP_SSH_IPADDR)"
run_lp "rm -rf ${NETSCRIPT_INSTALL}"
run_lp "mkdir -p ${NETSCRIPT_INSTALL}"
scp -r network-script/* root@$LP_SSH_IPADDR:${NETSCRIPT_INSTALL}
run_lp "echo ${LP_REPORT} > ${NETSCRIPT_INSTALL}/devrole.txt"

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

# Set the DUT's & LP's time to be consistent with Test Center's
# Note: DUT & LP's time is UTC-based and cannot be changed.
UTC_DATE=$(date -u +%Y%m%d)
run_dut "date -u +%Y%m%d -s $UTC_DATE"
run_lp "date -u +%Y%m%d -s $UTC_DATE"

UTC_TIME=$(date -u +%T)
TIME=$(date +%s)
run_dut "date -u +%s -s $UTC_TIME"
run_lp "date - u +%s -s $UTC_TIME"

## Install platform environment files
scp -r home/vimrc root@$DUT_SSH_IPADDR:~/.vimrc
scp -r home/vimrc root@$LP_SSH_IPADDR:~/.vimrc

## Install auto-reporting automation
scp self-report.sh root@$DUT_SSH_IPADDR:${NETSCRIPT_INSTALL}/self-report.sh
scp install-self-report.sh root@$DUT_SSH_IPADDR:${NETSCRIPT_INSTALL}/install-self-report.sh
scp -r network-script/etc/* root@$DUT_SSH_IPADDR:/etc/
run_dut "cd ${NETSCRIPT_INSTALL}; chmod a+x ./self-report.sh"
run_dut "cd ${NETSCRIPT_INSTALL}; chmod a+x ./install-self-report.sh; ./install-self-report.sh"

scp self-report.sh root@$LP_SSH_IPADDR:${NETSCRIPT_INSTALL}/self-report.sh
scp install-self-report.sh root@$LP_SSH_IPADDR:${NETSCRIPT_INSTALL}/install-self-report.sh
scp -r network-script/etc/* root@$LP_SSH_IPADDR:/etc/
run_lp "cd ${NETSCRIPT_INSTALL}; chmod a+x ./self-report.sh"
run_lp "cd ${NETSCRIPT_INSTALL}; chmod a+x ./install-self-report.sh; ./install-self-report.sh"

## Install & build TSN evaluator at DUT & LP
echo "scp tsn-evaluator to DUT($DUT_SSH_IPADDR)"
run_dut "mkdir -p ${NETSCRIPT_INSTALL}"
scp -r ${TC_HOME}/work/tsn-evaluator root@$DUT_SSH_IPADDR:${NETSCRIPT_INSTALL}
run_dut "cd ${NETSCRIPT_INSTALL}/tsn-evaluator; ./build.sh"

echo "scp tsn-evaluator to LP($LP_SSH_IPADDR)"
run_lp "mkdir -p ${NETSCRIPT_INSTALL}"
scp -r ${TC_HOME}/work/tsn-evaluator root@$LP_SSH_IPADDR:${NETSCRIPT_INSTALL}
run_lp "cd ${NETSCRIPT_INSTALL}/tsn-evaluator; ./build.sh"
