#!/bin/bash

unset LP_SSH_IPADDR
unset DUT_SSH_IPADDR
unset DUT_B2B_DEVNAME
unset DUT_B2B_IPADDR
unset LP_B2B_DEVNAME
unset LP_B2B_IPADDR

# SSH connection
export DUT_SSH_IPADDR="172.30.181.97"
export LP_SSH_IPADDR="172.30.181.80"

# DUT to LP B2B connection
export DUT_B2B_DEVNAME="enp0s30f4"
export DUT_B2B_IPADDR="192.168.1.100"
export LP_B2B_DEVNAME="enp2s0"
export LP_B2B_IPADDR="192.168.1.200"

alias aplbrd="ssh root@$LP_SSH_IPADDR"
alias ehlbrd="ssh root@$DUT_SSH_IPADDR"
