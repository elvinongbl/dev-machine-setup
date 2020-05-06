#!/bin/bash

source ./setup-global.sh
source ./helper-lib.sh

# setup static IP addr at B2B
print_banner "LP IP(static)=$LP_B2B_IPADDR"
remove_all_ipaddr $LP_B2B_DEVNAME
add_ipaddr $LP_B2B_DEVNAME $LP_B2B_IPADDR

# display Device information
display_eth_info $LP_B2B_DEVNAME "LP Eth"
