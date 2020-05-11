#!/bin/bash
#
# To run a series of autoneg change for speed and duplex

# include global library
source ../setup-global.sh
source ../helper-lib.sh
source ../ethtool-lib.sh

ROLE=$1
DEVNAME=$(role2devname $ROLE)
DEVIPADDR=$(role2ipaddr $ROLE)
PARTNERIPADDR=$(role2ipaddr $(role2lp $ROLE))

print_banner "Autoneg test on $ROLE ($DEVIPADDR)"
###
# Before run autoneg test, make sure LP is full duplex for all speeds
###
print_topic "Restore DUT and LP link mode and IP addr"
run_lp_restore_linkmode $ROLE
dut_restore_linkmode $ROLE
run_lp_restore_ipaddr $ROLE
dut_restore_ipaddr $ROLE

function test_autoneg () {
	local SPEED=$1
	local DUPLEX=$2
	print_topic "$SPEED-Mbps / $DUPLEX"
	ethtool_change_link $DEVNAME $SPEED $DUPLEX
	linkUp=$(ethtool_poll_link $DEVNAME)
	if [ x"$linkUp" == x"YES" ]; then
		echo "Link is up at $ROLE"
		ethtool_show_link $DEVNAME
		# Set IP addr for both DUT & LP
		run_lp_restore_ipaddr $ROLE
		dut_restore_ipaddr $ROLE
		# Ping Test
		print_separator_short
		ping -c 10 -s 56 -i 0.001 $PARTNERIPADDR
	else
		echo "ERROR!!!: Autoneg link DOWN at $SPEED/$DUPLEX"
	fi
}

test_autoneg 1000 full
test_autoneg 100 full
test_autoneg 10 full

###
# After run autoneg test, restore DUT to both duplex for all speeds
###
print_topic "Restore DUT and LP link mode and IP addr"
run_lp_restore_linkmode $ROLE
dut_restore_linkmode $ROLE
run_lp_restore_ipaddr $ROLE
dut_restore_ipaddr $ROLE
