#!/bin/bash

source ./setup-global.sh
source ./helper-lib.sh

# setup static IP addr at B2B
print_banner "Force DUT IP(static)=$DUT_B2B_IPADDR"
remove_all_ipaddr $DUT_B2B_DEVNAME
add_ipaddr $DUT_B2B_DEVNAME $DUT_B2B_IPADDR

# display Device information
display_eth_info $DUT_B2B_DEVNAME "DUT Eth"
