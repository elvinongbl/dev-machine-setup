#!/bin/bash

source ./setup-global.sh
source ./helper-lib.sh

ROLE=$1
set_target $ROLE

TARGET_HOME=$(role2home $ROLE)
ROLE_B2B_IPADDR=$(role2ipaddr $ROLE)
ROLE_B2B_DEVNAME=$(role2devname $ROLE)


# setup static IP addr at B2B
print_banner "Force DUT IP(static)=$ROLE_B2B_IPADDR"
remove_all_ipaddr $ROLE_B2B_DEVNAME
add_ipaddr $ROLE_B2B_DEVNAME $ROLE_B2B_IPADDR

# display Device information
display_eth_info $ROLE_B2B_DEVNAME "$ROLE Eth"

unset_target
