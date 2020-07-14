#!/bin/bash

# poll Link is detected. Return "YES" or "NO"
function ethtool_poll_link() {
	local DEVNAME=$1
	local i=0
	while [ $i -lt 10 ]
	do
 		linkup=$(ethtool $DEVNAME | grep "Link detected: yes" -c)
		if [ $linkup -eq 1 ]; then
			echo "YES"
			exit 0
		fi
		i=$[$i+1]
		sleep 1
	done
	echo "NO"
}

function ethtool_show_link() {
	local DEVNAME=$1
	run_cmd "ethtool $DEVNAME"
}

function ethtool_change_link() {
	local DEVNAME=$1
	local SP=$2
	local DUP=$3
	run_cmd "ethtool -s $DEVNAME duplex $DUP speed $SP autoneg on"
}

function ethtool_adv_cap() {
	local DEVNAME=$1
	local CAP=$2

	# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/s1-ethtool
	if [ x"$CAP" == x"10half" ]; then
		ADV=0x001
	fi

	if [ x"$CAP" == x"10full" ]; then
		ADV=0x002
	fi

	if [ x"$CAP" == x"100half" ]; then
		ADV=0x004
	fi

	if [ x"$CAP" == x"100full" ]; then
		ADV=0x008
	fi

	if [ x"$CAP" == x"1000half" ]; then
		ADV=0x010
	fi

	if [ x"$CAP" == x"1000full" ]; then
		ADV=0x020
	fi

	if [ x"$CAP" == x"2500full" ]; then
		ADV=0x8000
	fi

	if [ x"$CAP" == x"10000full" ]; then
		ADV=0x1000
	fi

	if [ x"$CAP" == x"20000mld2" ]; then
		ADV=0x20000
	fi

	if [ x"$CAP" == x"20000kr2" ]; then
		ADV=0x40000
	fi

	# Specials combo to help testing
	if [ x"$CAP" == x"10_1000full" ]; then
		ADV=0x2A
	fi

	if [ x"$CAP" == x"10_100half" ]; then
		ADV=0x05
	fi

	if [ x"$CAP" == x"10_1000both" ]; then
		ADV=0x3F
	fi

	run_cmd "ethtool -s $DEVNAME advertise $ADV"
}

# Make the LP's full capability as it is.
# Try 10M to 1000M both full & half duplex
function run_lp_restore_linkmode() {
	local ROLE=$1
	if [ x"$ROLE" == x"DUT" ]; then
		run_lp "source $NETSCRIPT_INSTALL/setup-global.sh; \
			source $NETSCRIPT_INSTALL/helper-lib.sh; \
			source $NETSCRIPT_INSTALL/ethtool-lib.sh; \
			ethtool_adv_cap $LP_B2B_DEVNAME 10_1000both; \
			"
	else
		run_dut "source $NETSCRIPT_INSTALL/setup-global.sh; \
			source $NETSCRIPT_INSTALL/helper-lib.sh; \
			source $NETSCRIPT_INSTALL/ethtool-lib.sh; \
			ethtool_adv_cap $DUT_B2B_DEVNAME 10_1000both \
			"
	fi
}

# Make the DUT's full capability as it is.
# Try 10M to 1000M both full & half duplex
function dut_restore_linkmode() {
	local ROLE=$1
	if [ x"$ROLE" == x"LP" ]; then
		ethtool_adv_cap $LP_B2B_DEVNAME 10_1000both
	else
		ethtool_adv_cap $DUT_B2B_DEVNAME 10_1000both
	fi
}
