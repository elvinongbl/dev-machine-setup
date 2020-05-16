#!/bin/bash
#
# To run a series of ping test for all packet sizes

# include global library
source ../setup-global.sh
source ../helper-lib.sh
source ../ethtool-lib.sh

ROLE=$1
DEVNAME=$(role2devname $ROLE)
DEVIPADDR=$(role2ipaddr $ROLE)
PARTNERIPADDR=$(role2ipaddr $(role2lp $ROLE))

print_banner "Ping test on $ROLE ($DEVIPADDR)"
###
# Before run autoneg test, make sure LP is full duplex for all speeds
###
print_topic "Restore DUT and LP link mode and IP addr"
run_lp_restore_linkmode $ROLE
dut_restore_linkmode $ROLE
run_lp_restore_ipaddr $ROLE
dut_restore_ipaddr $ROLE

function test_ping () {
	# Ping packet size is always +8-Byte
	SIZE=$[$1-8]
	COUNT=$2
	print_topic "Ping - size=$1 [count=$2]"
	ping -c $COUNT -s $SIZE -i 0.001 $PARTNERIPADDR
}

test_ping 64 64
test_ping 1514 64
