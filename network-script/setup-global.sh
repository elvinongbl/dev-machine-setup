#!/bin/bash

unset LP_SSH_IPADDR
unset DUT_SSH_IPADDR
unset DUT_B2B_DEVNAME
unset DUT_B2B_IPADDR
unset LP_B2B_DEVNAME
unset LP_B2B_IPADDR

# SSH connection
export DUT_SSH_IPADDR="172.30.181.114"
export LP_SSH_IPADDR="172.30.181.103"
export DUT_SSH_DEVNAME=enp0s20f0u4u4
export LP_SSH_DEVNAME=enp0s20f0u4u4

# DUT to LP B2B connection
export DUT_B2B_DEVNAME="enp0s29f1"
export DUT_B2B_IPADDR="192.168.1.1"
export LP_B2B_DEVNAME="enp0s29f1"
export LP_B2B_IPADDR="192.168.1.2"

# Target (DUT or LP) installation path
export DUT_HOME="/home/root"
export LP_HOME="/home/root"
export DUT_REPORT="EHL-A-DUT"
export LP_REPORT="EHL-B-LP"
export NETSCRIPT_INSTALL=${DUT_HOME}/network-script
export NETSCRIPT_LOG=${NETSCRIPT_INSTALL}/../test-logs

# DUT GOld Linux kernel version
export GOLDVER_FILE=${DUT_HOME}/.goldversion
export TESTVER_FILE=${DUT_HOME}/.testversion
export BACKUPVER_FILE=${DUT_HOME}/.backupversion

# Test Center
export TC_USER=sashimi
export TC_HOME=/home/${TC_USER}
export TC_LOGS=/home/${TC_USER}/test-logs
export TC_IPADDR="172.30.181.92"
export TC_PUBKEY="id_rsa.pub"

alias aplbrd="ssh root@$LP_SSH_IPADDR"
alias ehlbrd="ssh root@$DUT_SSH_IPADDR"
