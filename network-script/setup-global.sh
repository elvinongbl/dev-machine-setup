#!/bin/bash

unset LP_SSH_IPADDR
unset DUT_SSH_IPADDR
unset DUT_B2B_DEVNAME
unset DUT_B2B_IPADDR
unset LP_B2B_DEVNAME
unset LP_B2B_IPADDR

##############################################################
# Target Platform Selection
##############################################################

# SSH connection (EHL)
#export MACHINEARCH=EHL
#export DUT_SSH_IPADDR="12.30.18.10"
#export LP_SSH_IPADDR="12.30.18.10"
#export DUT_SSH_DEVNAME=enp0s20f0u4u4
#export LP_SSH_DEVNAME=enp0s20f0u4u4
#export TARGET_STMMAC_IFNAME="enp0s29f1"
#export TARGET_STMMAC_IFNAME="eth0"
#export TARGET_IGB_IFNAME="enp1s0"

# SSH connection (TGL)
export MACHINEARCH=TGL
export DUT_SSH_IPADDR="12.30.18.11"
export LP_SSH_IPADDR="12.30.18.11"
#export TARGET_STMMAC_IFNAME="enp0s30f4"
export TARGET_STMMAC_IFNAME="eth0"
export TARGET_IGB_IFNAME="enp1s0"

##############################################################
# NIC type Info
##############################################################

# STMMAC Info
STMMACIFNAME=$TARGET_STMMAC_IFNAME
STMMAC_SERVER_IP="169.254.1.11"
STMMAC_CLIENT_IP="169.254.1.22"

#IGB Info
IGBIFNAME=$TARGET_IGB_IFNAME
IGB_SERVER_IP="169.254.2.11"
IGB_CLIENT_IP="169.254.2.22"

##############################################################
# Network Test NIC Selection
##############################################################

# Network Test Target Machine & NIC (Integrated TSN)
TESTIFDEV=$STMMACIFNAME
TEST_DUT_IPADDR=$STMMAC_SERVER_IP
TEST_LP_IPADDR=$STMMAC_CLIENT_IP

# Network Test Target Machine & NIC (IGB)
#TESTIFDEV=$IGBIFNAME
#TEST_DUT_IPADDR=$IGB_SERVER_IP
#TEST_LP_IPADDR=$IGB_CLIENT_IP

##############################################################
# Network Test Common Configuration
##############################################################

# DUT to LP B2B connection
export DUT_B2B_DEVNAME=$TESTIFDEV
export DUT_B2B_IPADDR=$TEST_DUT_IPADDR
export LP_B2B_DEVNAME=$TESTIFDEV
export LP_B2B_IPADDR=$TEST_LP_IPADDR

# Target (DUT or LP) installation path
export DUT_HOME="/home/root"
export LP_HOME="/home/root"
export DUT_REPORT="${MACHINEARCH}-A-DUT"
export LP_REPORT="${MACHINEARCH}-B-LP"
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

##############################################################
# Linux Upgrade Information
##############################################################

export UPGRADE_LINUX_BUILD=${TC_HOME}/work/linux-otc-net
#export UPGRADE_LINUX=${UPGRADE_LINUX_BUILD}/linux-5.4.34-rt21-ehl+-x86.tar.xz
export UPGRADE_LINUX=${UPGRADE_LINUX_BUILD}/linux-5.4.49-ehl+-x86.tar.xz

