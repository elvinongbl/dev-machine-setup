#!/bin/bash

source ./setup-global.sh
source ./helper-lib.sh

# setup static IP addr at B2B
print_banner "Force DUT IP(static)=$DUT_B2B_IPADDR"
ip address add $DUT_B2B_IPADDR dev $DUT_B2B_DEVNAME

# display Device information
display_eth_info $DUT_B2B_DEVNAME "DUT Eth"
