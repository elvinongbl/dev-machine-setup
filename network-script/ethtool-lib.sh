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
	print_exe "ethtool $DEVNAME"
}

function ethtool_change_link() {
	local DEVNAME=$1
	local SP=$2
	local DUP=$3
	print_exe "ethtool -s $DEVNAME duplex $DUP speed $SP autoneg on"
}

function ethtool_adv_speed() {
	local DEVNAME=$1
	local SPEED=$2

	case "$SPEED" in
	1000)
		ADV=32
		;;
	100)
		ADV=8
		;;
	10)
		ADV=2
		;;
	esac

	print_exe "ethtool -s $DEVNAME advertise $ADV"
}
