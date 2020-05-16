#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

ROLE=$1
set_target $ROLE

TARGET_HOME=$(role2home $ROLE)
ROLE_SSH_IPADDR=$(role2sshipaddr $ROLE)
TARGET_REPORT=$(role2report $ROLE)

print_banner "install network-script @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"
run_target "rm -rf ${NETSCRIPT_INSTALL}"
run_target "mkdir -p ${NETSCRIPT_INSTALL}"
scp2target "-r network-script/*" ${NETSCRIPT_INSTALL}
run_target "echo ${TARGET_REPORT} > ${NETSCRIPT_INSTALL}/devrole.txt"

# Create new DUT ssh public key and add that to Test Center for scp test log
run_target "rm -rf ${TARGET_HOME}/.ssh"
run_target 'cat /dev/zero | ssh-keygen -q -N ""'
run_target_silence "cat ${TARGET_HOME}/.ssh/id_rsa.pub" >> ${TC_HOME}/.ssh/authorized_keys

# Set the DUT's & LP's time to be consistent with Test Center's
# Note: DUT & LP's time is UTC-based and cannot be changed.
print_topic "Sync time between Test Center and TARGET($ROLE:$ROLE_SSH_IPADDR)"
UTC_DATE=$(date -u +%Y%m%d)
run_target "date -u +%Y%m%d -s $UTC_DATE"

UTC_TIME=$(date -u +%T)
TIME=$(date +%s)
run_target "date -u +%s -s $UTC_TIME"

## Install platform environment files
scp2target "home/vimrc" "${TARGET_HOME}/.vimrc"

## Install auto-reporting automation
print_topic "Install self-reporting script @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"
scp2target "self-report.sh" "${NETSCRIPT_INSTALL}/self-report.sh"
scp2target "install-self-report.sh" "${NETSCRIPT_INSTALL}/install-self-report.sh"
scp2target "-r network-script/etc/*" "/etc/"
run_target "cd ${NETSCRIPT_INSTALL}; chmod a+x ./self-report.sh"
run_target "cd ${NETSCRIPT_INSTALL}; chmod a+x ./install-self-report.sh; ./install-self-report.sh"

## Install & build TSN evaluator at DUT & LP
print_topic "Install TSN evaluator @@ TARGET($ROLE:$ROLE_SSH_IPADDR)"
run_target "mkdir -p ${NETSCRIPT_INSTALL}"
scp2target "-r ${TC_HOME}/work/tsn-evaluator" "${NETSCRIPT_INSTALL}"
run_target "cd ${NETSCRIPT_INSTALL}/tsn-evaluator; ./build.sh"

## Install & build TSN evaluator at DUT & LP
print_banner "Setup TARGET($ROLE:$ROLE_SSH_IPADDR)"
run_target "cd ${NETSCRIPT_INSTALL}; ./setup-target.sh $ROLE"

unset_target
