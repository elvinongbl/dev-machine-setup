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

function test_autoneg () {
	local SPEED=$1
	local DUPLEX=$2
	print_topic "$SPEED-Mbps / $DUPLEX"
	ethtool_change_link $DEVNAME $SPEED $DUPLEX
	linkUp=$(ethtool_poll_link $DEVNAME)
	if [ x"$linkUp" == x"YES" ]; then
		echo "Link is up at $ROLE"
		ethtool_show_link $DEVNAME
		add_ipaddr $DEVNAME $DEVIPADDR
		print_separator_short
		ping -c 10 -s 56 -i 0.001 $PARTNERIPADDR
	else
		echo "ERROR!!!: Autoneg link DOWN at $SPEED/$DUPLEX"
	fi
}

test_autoneg 1000 full
test_autoneg 100 full
test_autoneg 10 full
