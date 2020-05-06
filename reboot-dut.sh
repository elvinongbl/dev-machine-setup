#!/bin/bash

source ./network-script/setup-global.sh
source ./network-script/helper-lib.sh

print_banner "Reboot DUT IP = $DUT_SSH_IPADDR"
run_dut "reboot"
