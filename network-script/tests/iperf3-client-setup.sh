#!/bin/bash

# include global library
source ../setup-global.sh
source ../helper-lib.sh
source ../ethtool-lib.sh

function stmmac_setup () {
	local IFNAME=$STMMACIFNAME
	local IFIPADDR=$STMMAC_CLIENT_IP

	remove_all_ipaddr $IFNAME;
	sleep 1
	add_ipaddr $IFNAME $IFIPADDR;

	run_cmd	"ethtool -L $IFNAME rx 6 tx 4"

	run_cmd "ethtool --per-queue $IFNAME queue_mask 0x01 --coalesce tx-frames 1 tx-usecs 1000"
	run_cmd "ethtool --show-coalesce $IFNAME"

	# Remap RXQ0 & TXQ0 to CPU1 (1<<1=2)
	eth_irqaffinity_remap $IFNAME rx-0 2
	eth_irqaffinity_remap $IFNAME tx-0 2
}

function igb_setup () {
	local IFNAME=$IGBIFNAME
	local IFIPADDR=$IGB_CLIENT_IP

	remove_all_ipaddr $IFNAME;
	sleep 1
	add_ipaddr $IFNAME $IFIPADDR;

	run_cmd "ethtool -L $IFNAME rx 1 tx 1"
	run_cmd "ethtool --show-coalesce $IFNAME"

	# Remap RXQ0 & TXQ0 to CPU1 (1<<1=2)
	eth_irqaffinity_remap $IFNAME TxRx-0 2
}

echo -e "iperf client setup = stmmac [$STMMACIFNAME@$STMMAC_CLIENT_IP]"
stmmac_setup

#echo -e "iperf client setup = igb [$IGBIFNAME@$IGB_CLIENT_IP]"
#igb_setup
